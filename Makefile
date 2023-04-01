.PHONY=build install clean

SIGNAL_VERSION=$$(cat ./SIGNAL_VERSION | tr -d vV)
FEDORA_VERSION=$$(cat ./FEDORA_VERSION)
PATCH_FILE="Signal-Desktop.patch"
ARCH=$$(if [[ "$$(uname -m)" == "aarch64" ]]; then echo "arm64v8"; else echo "amd64"; fi)

all: build

build: clean
	@mkdir -p output
	@podman build --build-arg=ARCH=$(ARCH) --build-arg=FEDORA_VERSION=$(FEDORA_VERSION) --build-arg=PATCH_FILE=$(PATCH_FILE) -t signal-desktop-rpm:latest .
	@podman run -it --rm -v $$PWD/output:/output:Z -e SIGNAL_VERSION=$(SIGNAL_VERSION) signal-desktop-rpm:latest

install:
	@-pkill --signal SIGHUP -x signal-desktop >/dev/null 2>/dev/null && sleep 2
	@-pkill --signal SIGKILL -x signal-desktop >/dev/null 2>/dev/null
	@sudo rpm -Uvh --force output/signal-desktop-$(SIGNAL_VERSION).x86_64.rpm
	@sudo sed -i 's|Exec=/opt/Signal/signal-desktop.*|Exec=/opt/Signal/signal-desktop --use-tray-icon %U|g' /usr/share/applications/signal-desktop.desktop

clean:
	@podman unshare rm -rf ./output
	@-podman rm -f signal-desktop-rpm 2>/dev/null
