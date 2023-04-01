ARG FEDORA_VERSION
FROM docker.io/arm64v8/fedora:${FEDORA_VERSION}

# Install build requirements
RUN dnf update -y && \
    dnf install -y unzip g++ npm python make gcc git rpm-build libxcrypt-compat patch ruby && \
    gem install fpm && \
# Install git-lfs
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && \
    dnf install -y git-lfs && \
    git lfs install && \
    dnf clean all

# Install yarn and nvm
ENV NVM_DIR /root/.nvm
RUN npm install --global yarn && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

#Add patch file
ARG PATCH_FILE
COPY ${PATCH_FILE} /root/Signal-Desktop.patch

# Add entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
