#!/bin/bash

set -euo pipefail
#環境変数の設定
KUBERNETES_VERSION=1.26.1
IPADDR=$(ip a show ens3 | grep inet | grep -v inet6 | awk '{print $2}' | cut -f1 -d/)
WORKER1_IPADDR=192.168.0.210
WORKER2_IPADDR=192.168.0.218
WORKER3_IPADDR=192.168.0.222


echo kubeadm で kubernetes インストール
sudo kubeadm init \
  --control-plane-endpoint="${IPADDR}" \
  --apiserver-advertise-address="${IPADDR}" \
  --kubernetes-version="v1.26.1" \
  --pod-network-cidr="172.16.0.0/16" \
  --upload-certs

echo ディレクトリ周りの設定
mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config

mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

echo "source <(kubectl completion bash)" >> /home/ubuntu/.bashrc

echo デフォルトCNIの設定
kubectl apply -f kf.yml

echo join用のファイル生成
cat <<EOF | tee /home/ubuntu/join-worker.sh
#!/bin/bash
sudo $(kubeadm token create --print-join-command)
EOF
chmod +x /home/ubuntu/join-worker.sh

echo Workerにjoin用のファイルを転送
scp -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_ed25519 /home/ubuntu/join-worker.sh ubuntu@${WORKER1_IPADDR}:/home/ubuntu/
scp -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_ed25519 /home/ubuntu/join-worker.sh ubuntu@${WORKER2_IPADDR}:/home/ubuntu/
scp -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_ed25519 /home/ubuntu/join-worker.sh ubuntu@${WORKER3_IPADDR}:/home/ubuntu/