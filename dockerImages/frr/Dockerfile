FROM --platform=linux/x86_64 ubuntu:20.04

# 必要なパッケージをインストール
RUN apt-get update && \
    apt-get install -y nano vim git dh-autoreconf libexpat1-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["bash", "-c", "sleep infinity"]