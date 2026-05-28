#!/bin/bash

set -euo pipefail

echo "------ Building Signal-Desktop v${SIGNAL_VERSION} ${ARCH} ------"

# Clone and patch Signal-Desktop
cd /root
git clone -b "v${SIGNAL_VERSION}" --depth 1 https://github.com/signalapp/Signal-Desktop.git
cd Signal-Desktop
patch -p1 </root/Signal-Desktop.patch
if [ "$PATCH_FILE" != "Signal-Desktop.patch" ]; then
	echo "Applying additional patch: $PATCH_FILE"
	patch -p1 <"/root/$PATCH_FILE"
fi

# Build Signal-Desktop
export USE_SYSTEM_FPM=true
# shellcheck disable=SC2155
export SOURCE_DATE_EPOCH="$(date +"%s")"
pnpm install --frozen-lockfile
pnpm run clean-transpile
cd sticker-creator
pnpm install --frozen-lockfile
pnpm run build
cd ..
pnpm run generate
pnpm run prepare-beta-build
if [ "$ARCH" = "amd64" ]; then
	BUILD_ARCH="x64"
elif [ "$ARCH" = "arm64v8" ]; then
	BUILD_ARCH="arm64"
else
	echo "Unsupported architecture: $ARCH"
	exit 1
fi
pnpm run prepare-linux-build "rpm" "$BUILD_ARCH"
pnpm run build-linux

# Export rpm
mkdir -p /output
find /root/Signal-Desktop -name "*.rpm" -exec cp {} /output/ \;

echo -e "\e[42;30mDone !\e[0m"
