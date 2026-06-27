ARG ARCH
ARG FEDORA_VERSION
FROM docker.io/${ARCH}/fedora:${FEDORA_VERSION}

# Install build requirements
RUN dnf update -y \
    && dnf install -y g++ python make gcc git rpm-build libxcrypt-compat pulseaudio-libs-devel patch jq \
    && dnf install -y ruby-devel && gem install fpm \
    && dnf clean all

# Add patch files
COPY ./patch/ /root/

# Add entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV SIGNAL_ENV=production

WORKDIR /root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
