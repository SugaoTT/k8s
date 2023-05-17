#!/bin/bash

set -euo pipefail

#環境変数の設定
KUBERNETES_VERSION=1.26.1-00
IPADDR=$(ip a show ens3 | grep inet | grep -v inet6 | awk '{print $2}' | cut -f1 -d/)

echo  nameserver 8.8.8.8 >> /etc/resolv.conf
echo swapをオフにします
swapoff -a
sudo sed -i '/swap.img/s/^/#/' /etc/fstab

echo カーネルモジュールのロード
modprobe br_netfilter
modprobe overlay

echo カーネルモジュールの確認
lsmod | grep -e br_netfilter -e overlay

echo 再起動後にも有効にするため設定ファイルを作成
cat >/etc/modules-load.d/containerd.conf <<EOF
br_netfilter
overlay
EOF

echo カーネルパラメータの設定
cat >/etc/sysctl.d/99-containerd.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

echo カーネルパラメータ適用
sysctl --system

echo 適用の確認
sysctl -a | grep -e bridge-nf-call-ip -e ip_forward

echo https 越しのリポジトリ利用のための準備
apt-get update && \
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

echo Docker 公式の GPG 鍵の追加
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

echo Docker のリポジトリ追加
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

echo containerd のインストール
apt-get update && apt-get install -y containerd.io

echo containerd の 設定ファイルを削除して再起動
rm /etc/containerd/config.toml
systemctl restart containerd

echo k8sのインストールをします
echo google の GPG 鍵の追加
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo Kubernetes レポジトリの追加
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

echo 各パッケージのインストール
apt-get update && sudo apt-get install -y kubelet=${KUBERNETES_VERSION} kubeadm=${KUBERNETES_VERSION} kubectl=${KUBERNETES_VERSION}
sudo apt-mark hold kubelet kubeadm kubectl

echo eth1の情報を使用するようにk8sクラスタに登録
IPADDR=$(ip a show ens3 | grep inet | grep -v inet6 | awk '{print $2}' | cut -f1 -d/)
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--node-ip=${IPADDR}
EOF

echo kubeletを再起動
sudo systemctl daemon-reload
sudo systemctl restart kubelet