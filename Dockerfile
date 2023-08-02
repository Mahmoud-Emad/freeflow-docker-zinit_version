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
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential cargo curl git lsb-release libclang-dev \
    && git clone "https://github.com/yggdrasil-network/yggdrasil-go.git" /src \
    && cd /src \
    && git reset --hard v${YGGDRASIL_VERSION} \
    && curl -LO "https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" \
    && tar -C /usr/local -xzf "go${GOLANG_VERSION}.linux-amd64.tar.gz" \
    && export PATH=$PATH:/usr/local/go/bin \
    && ./build \
    && curl -sSfLo /tmp/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64" \
    && chmod 0755 /tmp/dumb-init

# Install redis, redis-json, redis-search
RUN apt-get update -y && apt-get upgrade -y \
 && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y curl software-properties-common build-essential llvm cmake libclang1 libclang-dev cargo

RUN curl https://packages.redis.io/gpg | apt-key add - \
 && echo "deb https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list \
 && apt-get update -y \
 && apt-get install -y redis

# Build RedisJSON
RUN git clone "https://github.com/RedisJSON/RedisJSON.git" /redis-json \
 && cd /redis-json \
 && cargo fix --edition \
 && cargo build --release

RUN git clone --recursive "https://github.com/RediSearch/RediSearch.git" /redis-search \
 && cd /redis-search \
 && make setup \
 && make build

# Install Node.js and PM2
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash \
 && export NVM_DIR="$HOME/.nvm" \
 && [ -s "$NVM_DIR/nvm.sh" ] \
 && \. "$NVM_DIR/nvm.sh" \
 && [ -s "$NVM_DIR/bash_completion" ] \
 && \. "$NVM_DIR/bash_completion" bash_completion \
 && npm install pm2@5.2.2 -g \
 && npm install \
 && npm run build

# Install zinit
RUN curl -Lo /sbin/zinit https://github.com/threefoldtech/zinit/releases/download/v0.2.10/zinit \
 && chmod +x /sbin/zinit

# Create required dirs
RUN mkdir /var/log/yggdrasil \
    mkdir /appdata \
    mkdir /appdata/user \
    mkdir -p /etc/zinit

# Coping...
# Copy ygg things
COPY /src/yggdrasil    /usr/bin/
COPY /src/yggdrasilctl /usr/bin/
COPY /tmp/dumb-init    /usr/bin/

# Copy the build files
COPY /freeflow/apps/frontend/dist /usr/share/nginx/html

# Copy errors folder and ngnix.conf
COPY ./error/public /usr/share/nginx/error
COPY ./error/error-nginx.conf /var/tmp/error-nginx.conf
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy redis conf
COPY /redis-json /redis-json
COPY /redis-search /redis-search


