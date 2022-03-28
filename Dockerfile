FROM fedora:35
ARG SIGNAL_VERSION

RUN dnf update -y && \
    dnf install -y unzip g++ npm python make gcc git rpm-build libxcrypt-compat patch

# Install git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && \
    dnf install -y git-lfs && \
    git lfs install

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

# Build Signal-Desktop
RUN cd /root/Signal-Desktop && \
    source /root/.nvm/nvm.sh --no-use && \
    nvm use && \
    yarn install --frozen-lockfileyarn && \
    yarn generate && \
    yarn build-release
