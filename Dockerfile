ARG FEDORA_VERSION
FROM docker.io/fedora:${FEDORA_VERSION}

# Install build requirements
RUN dnf update -y && \
    dnf install -y unzip g++ npm python make gcc git rpm-build libxcrypt-compat patch && \
# Install git-lfs
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && \
    dnf install -y git-lfs && \
    git lfs install && \
    dnf clean all

ENV NVM_DIR /root/.nvm

#Add patch file
ARG PATCH_FILE
COPY ${PATCH_FILE} /root/Signal-Desktop.patch

# Add entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
