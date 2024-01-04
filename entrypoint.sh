#!/bin/bash

set -e
set -u

# Install nvm version used by Signal-Desktop
source /root/.nvm/nvm.sh --no-use
nvm install $(curl -o- https://raw.githubusercontent.com/signalapp/Signal-Desktop/v${SIGNAL_VERSION}/.nvmrc)

# Clone and patch Signal-Desktop
cd /root
git clone -b v${SIGNAL_VERSION} --depth 1 https://github.com/signalapp/Signal-Desktop.git
cd Signal-Desktop
patch -p1 </root/Signal-Desktop.patch

# Build Signal-Desktop
nvm use
if [[ "${ARCH}" == "arm64v8" ]]; then export USE_SYSTEM_FPM=true; fi
yarn install --frozen-lockfile
yarn generate
yarn build-release

# Export rpm and clean
mkdir -p /output
cp /root/Signal-Desktop/release/signal-desktop-*.rpm /output
cd /root
rm -rf /root/Signal-Desktop
yarn cache clean --all
npm cache clean --force

echo -e "\e[42;30mDone !\e[0m"
