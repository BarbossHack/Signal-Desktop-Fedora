FROM fedora:35
ARG SIGNAL_VERSION

RUN dnf update -y && \
    dnf install -y unzip g++ npm python make gcc git rpm-build libxcrypt-compat

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

# Clone Signal-Desktop
RUN cd /root && \
    git clone https://github.com/signalapp/Signal-Desktop.git && \
    cd Signal-Desktop && \
    git checkout v${SIGNAL_VERSION}

# Build Signal-Desktop
RUN cd /root/Signal-Desktop && \
    source /root/.nvm/nvm.sh --no-use && \
    nvm use && \
    sed -i 's/^ *"deb"$/"rpm"/g' package.json && \
    yarn install --frozen-lockfileyarn && \
    yarn generate && \
    yarn build-release
