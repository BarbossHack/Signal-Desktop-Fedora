.PHONY=build install clean

SIGNAL_VERSION=$$(cat ./SIGNAL_VERSION | head -n 1 | tr -d vV)
FEDORA_VERSION=$$(cat ./FEDORA_VERSION | head -n 1)
PATCH_FILE="Signal-Desktop.patch"
ARCH=$$(if [[ "$$(uname -m)" == "aarch64" ]]; then echo "arm64v8"; else echo "amd64"; fi)
NODE_VERSION=$$(curl -s "https://raw.githubusercontent.com/signalapp/Signal-Desktop/refs/tags/v$(SIGNAL_VERSION)/.nvmrc")

all: build

build: clean
	@mkdir -p output
	@podman build --build-arg=ARCH=$(ARCH) --build-arg=FEDORA_VERSION=$(FEDORA_VERSION) --build-arg=PATCH_FILE=$(PATCH_FILE) --build-arg NODE_VERSION=$(NODE_VERSION) --build-arg=SIGNAL_VERSION=$(SIGNAL_VERSION) -t signal-desktop-rpm:latest .
	@podman run -it --rm -v $$PWD/output:/output:Z signal-desktop-rpm:latest

install:
	@-pkill --signal SIGHUP -x signal-desktop >/dev/null 2>/dev/null && sleep 2
	@-pkill --signal SIGKILL -x signal-desktop >/dev/null 2>/dev/null
	@sudo rpm -Uvh --force output/signal-desktop-$(SIGNAL_VERSION).$$(uname -m).rpm
	@sudo sed -i 's|Exec=/opt/Signal/signal-desktop.*|Exec=/opt/Signal/signal-desktop --use-tray-icon %U|g' /usr/share/applications/signal-desktop.desktop

clean:
	@podman unshare rm -rf ./output
	@-podman rm -f signal-desktop-rpm 2>/dev/null
