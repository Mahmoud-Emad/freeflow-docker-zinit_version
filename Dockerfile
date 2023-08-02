FROM ubuntu:20.04

# Set work dir
WORKDIR /freeflow

# Set environment variables for NVM, Go, and Yggdrasil installation
ENV DUMB_INIT_VERSION=1.2.2 \
    NODE_VERSION=v16.18.1 \
    GOLANG_VERSION=1.17.1 \
    YGGDRASIL_VERSION=0.4.0

# Update the packages and install some system, Go, and Yggdrasil packages
RUN set -ex \
    && apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential curl git \
    && git clone "https://github.com/yggdrasil-network/yggdrasil-go.git" /src \
    && cd /src \
    && git reset --hard v${YGGDRASIL_VERSION} \
    && curl -LO "https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" \
    && tar -C /usr/local -xzf "go${GOLANG_VERSION}.linux-amd64.tar.gz" \
    && export PATH=$PATH:/usr/local/go/bin \
    && ./build \
    && curl -sSfLo /tmp/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64" \
    && chmod 0755 /tmp/dumb-init

# Install Node.js and PM2
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash \
 && export NVM_DIR="$HOME/.nvm" \
 && [ -s "$NVM_DIR/nvm.sh" ] \
 && \. "$NVM_DIR/nvm.sh" \
 && [ -s "$NVM_DIR/bash_completion" ] \
 && \. "$NVM_DIR/bash_completion" bash_completion \
 && npm install pm2@5.2.2 -g
