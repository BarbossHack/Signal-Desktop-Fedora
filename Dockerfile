ARG FEDORA_VERSION
FROM docker.io/fedora:${FEDORA_VERSION}

RUN dnf update -y && \
    dnf install -y unzip g++ npm python make gcc git rpm-build libxcrypt-compat patch

# Install git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && \
    dnf install -y git-lfs && \
    git lfs install

ARG SIGNAL_VERSION

# Install yarn and nvm
ENV NVM_DIR /root/.nvm
RUN npm install --global yarn && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
    source /root/.nvm/nvm.sh --no-use && \
    nvm install $(curl -o- https://raw.githubusercontent.com/signalapp/Signal-Desktop/v${SIGNAL_VERSION}/.nvmrc)

# Clone and patch Signal-Desktop
COPY package.json.patch /root/package.json.patch
RUN cd /root && \
    git clone -b v${SIGNAL_VERSION} --depth 1 https://github.com/signalapp/Signal-Desktop.git && \
    patch /root/Signal-Desktop/package.json /root/package.json.patch

# Temporary fix for https://github.com/BarbossHack/Signal-Desktop-Fedora/issues/2
COPY package.json.better-sqlite3.patch /root/package.json.better-sqlite3.patch
RUN git clone -c "lfs.fetchexclude=deps/sqlcipher.tar.gz" https://github.com/signalapp/better-sqlite3/ /root/Signal-Desktop/node_modules/better-sqlite3 && \
    cd /root/Signal-Desktop/node_modules/better-sqlite3 && \
    git checkout 3c4a7eebba3d5f5d8cb88fe83be1c01b8c0dea7d && \
    patch /root/Signal-Desktop/package.json /root/package.json.better-sqlite3.patch && \
    curl -L https://www.dropbox.com/s/bkuowgx6jb6n0y3/sqlcipher.tar.gz -o /root/Signal-Desktop/node_modules/better-sqlite3/deps/sqlcipher.tar.gz && \
    # Check sha256sum from https://github.com/signalapp/better-sqlite3/blob/3c4a7eebba3d5f5d8cb88fe83be1c01b8c0dea7d/deps/sqlcipher.tar.gz
    echo "fe8bdc5e2f182970fb63a71ec4c519c8192453800bf142f755d7ed99e79fff84 /root/Signal-Desktop/node_modules/better-sqlite3/deps/sqlcipher.tar.gz" | sha256sum -c

# Build Signal-Desktop
RUN cd /root/Signal-Desktop && \
    source /root/.nvm/nvm.sh --no-use && \
    nvm use && \
    yarn install --frozen-lockfileyarn && \
    yarn generate && \
    yarn build-release
