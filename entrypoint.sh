#!/bin/bash
# shellcheck disable=SC2155

set -euo pipefail

echo "------ Building Signal-Desktop v${SIGNAL_VERSION} ${ARCH} ------"

# Install nvm
export NVM_VERSION="$(curl -sfL "https://raw.githubusercontent.com/signalapp/Signal-Desktop/refs/tags/v${SIGNAL_VERSION}/reproducible-builds/Dockerfile" | grep "ENV NVM_VERSION=" | cut -d= -f2)"
export NODE_VERSION="$(curl -sfL "https://raw.githubusercontent.com/signalapp/Signal-Desktop/refs/tags/v${SIGNAL_VERSION}/.nvmrc")"
export NVM_DIR=/usr/local/nvm
mkdir "$NVM_DIR"
curl -sfL -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash
# shellcheck disable=SC1091
. $NVM_DIR/nvm.sh
nvm install "$NODE_VERSION"
nvm alias "$NODE_VERSION"
nvm use "$NODE_VERSION"
export NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules
export PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"

# Install pnpm
npm install -g "$(curl -sfL "https://github.com/signalapp/Signal-Desktop/raw/refs/tags/v${SIGNAL_VERSION}/package.json" | jq -r .packageManager)"

# Clone and patch Signal-Desktop
cd /root
git clone -b "v${SIGNAL_VERSION}" --depth 1 https://github.com/signalapp/Signal-Desktop.git
cd Signal-Desktop
patch -p1 </root/Signal-Desktop.patch
if [ "$PATCH_FILE" != "Signal-Desktop.patch" ]; then
	echo "Applying additional patch: $PATCH_FILE"
	patch -p1 <"/root/$PATCH_FILE"
fi
# temporary fix to ignore outdated pnpm-lock.yaml, may not be needed later
sed -i 's/verifyDepsBeforeRun: prompt/verifyDepsBeforeRun: warn/g' pnpm-workspace.yaml

# Build Signal-Desktop
export USE_SYSTEM_FPM=true
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
