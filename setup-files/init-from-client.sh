#!/bin/bash

set -euo pipefail
#環境変数の設定
MASTER_IPADDR=192.168.0.224
WORKER1_IPADDR=192.168.0.210
WORKER2_IPADDR=192.168.0.218
WORKER3_IPADDR=192.168.0.222

echo Masterにファイル転送
scp ./kf.yml ubuntu@${MASTER_IPADDR}:~/
scp ./setup-k8s-common.sh ubuntu@${MASTER_IPADDR}:~/
scp ./setup-k8s-master.sh ubuntu@${MASTER_IPADDR}:~/

echo Worker1にファイル転送
scp ./setup-k8s-common.sh ubuntu@${WORKER1_IPADDR}:~/
scp ./setup-k8s-worker.sh ubuntu@${WORKER1_IPADDR}:~/

echo Worker2にファイル転送
scp ./setup-k8s-common.sh ubuntu@${WORKER2_IPADDR}:~/
scp ./setup-k8s-worker.sh ubuntu@${WORKER2_IPADDR}:~/

echo Worker3にファイル転送
scp ./setup-k8s-common.sh ubuntu@${WORKER3_IPADDR}:~/
scp ./setup-k8s-worker.sh ubuntu@${WORKER3_IPADDR}:~/