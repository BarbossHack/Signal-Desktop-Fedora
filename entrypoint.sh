#!/bin/bash

set -e
set -u

echo "SIGNAL_VERSION: ${SIGNAL_VERSION}"

# Install yarn and nvm
npm install --global yarn
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source /root/.nvm/nvm.sh --no-use
nvm install $(curl -o- https://raw.githubusercontent.com/signalapp/Signal-Desktop/v${SIGNAL_VERSION}/.nvmrc)

# Clone and patch Signal-Desktop
cd /root
git clone -b v${SIGNAL_VERSION} --depth 1 https://github.com/signalapp/Signal-Desktop.git
cd Signal-Desktop
patch -p1 </root/Signal-Desktop.patch

# Build Signal-Desktop
source /root/.nvm/nvm.sh --no-use
nvm use
yarn install --frozen-lockfileyarn
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
