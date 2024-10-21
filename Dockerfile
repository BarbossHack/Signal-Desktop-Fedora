ARG ARCH
ARG FEDORA_VERSION
FROM docker.io/${ARCH}/fedora:${FEDORA_VERSION}

# Install build requirements
ARG ARCH
ENV ARCH ${ARCH}
RUN dnf update -y \
    && dnf install -y g++ npm python make gcc git rpm-build libxcrypt-compat patch \
    && if [[ "${ARCH}" == "arm64v8" ]]; then dnf install -y ruby-devel && gem install fpm; fi \
    && dnf clean all

# Install nvm
ARG NODE_VERSION
ENV NVM_VERSION=0.40.1
ENV NVM_DIR=/usr/local/nvm
RUN mkdir $NVM_DIR
RUN curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias $NODE_VERSION \
    && nvm use $NODE_VERSION
ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Add patch file
ARG PATCH_FILE
COPY ${PATCH_FILE} /root/Signal-Desktop.patch

# Add entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV SIGNAL_ENV=production

WORKDIR /root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
