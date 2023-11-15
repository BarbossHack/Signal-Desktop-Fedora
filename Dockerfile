ARG ARCH
ARG FEDORA_VERSION
FROM docker.io/${ARCH}/fedora:${FEDORA_VERSION}

ARG ARCH
ENV ARCH ${ARCH}

# Install build requirements
RUN dnf update -y && \
    dnf install -y unzip g++ npm python make gcc git rpm-build libxcrypt-compat patch && \
    if [[ "${ARCH}" == "arm64v8" ]]; then dnf install -y ruby && gem install fpm; fi && \
# Install git-lfs
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && \
    dnf install -y git-lfs && \
    git lfs install && \
    dnf clean all

# Install yarn and nvm
ENV NVM_DIR /root/.nvm
RUN npm install --global yarn && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# Add patch file
ARG PATCH_FILE
COPY ${PATCH_FILE} /root/Signal-Desktop.patch

# Add entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
