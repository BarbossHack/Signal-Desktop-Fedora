ARG FEDORA_VERSION
FROM docker.io/fedora:${FEDORA_VERSION}

RUN dnf update -y && \
    dnf install -y unzip g++ npm python make gcc git rpm-build libxcrypt-compat patch && \
    dnf clean all

# Install git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && \
    dnf install -y git-lfs && \
    git lfs install && \
    dnf clean all

ARG SIGNAL_VERSION

# Install yarn and nvm
ENV NVM_DIR /root/.nvm
RUN npm install --global yarn && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash && \
    source /root/.nvm/nvm.sh --no-use && \
    nvm install $(curl -o- https://raw.githubusercontent.com/signalapp/Signal-Desktop/v${SIGNAL_VERSION}/.nvmrc)

# Clone and patch Signal-Desktop
ARG PATCH_FILE
COPY ${PATCH_FILE} /root/Signal-Desktop.patch
RUN cd /root && \
    git clone -b v${SIGNAL_VERSION} --depth 1 https://github.com/signalapp/Signal-Desktop.git && \
    cd Signal-Desktop && \
    patch -p1 < /root/Signal-Desktop.patch && \
# Build Signal-Desktop
    source /root/.nvm/nvm.sh --no-use && \
    nvm use && \
    yarn install --frozen-lockfileyarn && \
    yarn generate && \
    yarn build-release && \
# Export rpm and clean
    mkdir -p /output && \
    cp /root/Signal-Desktop/release/signal-desktop-*.rpm /output && \
    cd /root && \
    rm -rf /root/Signal-Desktop && \
    yarn cache clean --all && \
    npm cache clean --force && \
    echo "Done !"
