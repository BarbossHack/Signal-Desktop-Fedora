#!/bin/bash

set -eu

echo "------ Building Signal-Desktop v${SIGNAL_VERSION} ------"

# Clone and patch Signal-Desktop
cd /root
git clone -b v${SIGNAL_VERSION} --depth 1 https://github.com/signalapp/Signal-Desktop.git
cd Signal-Desktop
patch -p1 </root/Signal-Desktop.patch

# Build Signal-Desktop
export USE_SYSTEM_FPM=true
pnpm install --frozen-lockfile
pnpm run clean-transpile
cd sticker-creator
pnpm install --frozen-lockfile
pnpm run build
cd ..
pnpm run generate
pnpm run prepare-beta-build
pnpm run build-linux

# Export rpm
mkdir -p /output
cp /root/Signal-Desktop/release/signal-desktop-*.rpm /output/

echo -e "\e[42;30mDone !\e[0m"
