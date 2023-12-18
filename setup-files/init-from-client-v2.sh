#!/bin/bash

set -euo pipefail
#環境変数の設定
MASTER_IPADDR=192.168.0.242
WORKER1_IPADDR=192.168.0.241
WORKER2_IPADDR=192.168.0.193

echo Masterにファイル転送
scp ./kf.yml ubuntu@${MASTER_IPADDR}:~/
scp ./setup-k8s-common.sh ubuntu@${MASTER_IPADDR}:~/
scp ./setup-k8s-master-v2.sh ubuntu@${MASTER_IPADDR}:~/

echo Worker1にファイル転送
scp ./setup-k8s-common.sh ubuntu@${WORKER1_IPADDR}:~/
scp ./setup-k8s-worker.sh ubuntu@${WORKER1_IPADDR}:~/

echo Worker2にファイル転送
scp ./setup-k8s-common.sh ubuntu@${WORKER2_IPADDR}:~/
scp ./setup-k8s-worker.sh ubuntu@${WORKER2_IPADDR}:~/