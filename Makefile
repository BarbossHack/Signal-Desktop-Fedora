.PHONY=build install clean update

SIGNAL_VERSION=$$(cat ./SIGNAL_VERSION | head -n 1 | tr -d vV)
FEDORA_VERSION=$$(cat ./FEDORA_VERSION | head -n 1)
PATCH_FILE="Signal-Desktop.patch"
ARCH=$$(if [[ "$$(uname -m)" == "aarch64" ]]; then echo "arm64v8"; else echo "amd64"; fi)
NODE_VERSION=$$(curl -s "https://raw.githubusercontent.com/signalapp/Signal-Desktop/refs/tags/v$(SIGNAL_VERSION)/.nvmrc")

all: build

build: clean
	@mkdir -p output
	@podman build --build-arg=ARCH=$(ARCH) --build-arg=FEDORA_VERSION=$(FEDORA_VERSION) --build-arg=PATCH_FILE=$(PATCH_FILE) --build-arg NODE_VERSION=$(NODE_VERSION) -t signal-desktop-rpm:latest .
	@podman run -it --rm -e SIGNAL_VERSION=$(SIGNAL_VERSION) -v $$PWD/output:/output:Z signal-desktop-rpm:latest

install:
	@-pkill --signal SIGHUP -x signal-desktop >/dev/null 2>/dev/null && sleep 2
	@-pkill --signal SIGKILL -x signal-desktop >/dev/null 2>/dev/null
	@sudo rpm -Uvh --force output/signal-desktop-$(SIGNAL_VERSION).$$(uname -m).rpm
	@sudo sed -i 's|Exec=/opt/Signal/signal-desktop.*|Exec=/opt/Signal/signal-desktop --use-tray-icon %U|g' /usr/share/applications/signal-desktop.desktop

clean:
	@podman unshare rm -rf ./output
	@-podman rm -f signal-desktop-rpm 2>/dev/null

update:
	@SIGNAL_VERSION=$$(git ls-remote --tags https://github.com/signalapp/Signal-Desktop.git | awk -F/ '{print $$NF}' | grep -v '\-alpha' | grep -v '\-beta' | grep -v '\^{}' | sort -V | tail -n 1) && echo "SIGNAL_VERSION: $$SIGNAL_VERSION" && echo -n $$SIGNAL_VERSION > SIGNAL_VERSION && sed -i "s/^- Signal-Desktop v.*/- Signal-Desktop $$SIGNAL_VERSION/g" README.md
	@FEDORA_VERSION=$$(if [ -f /etc/os-release ]; then . /etc/os-release && [ "$$ID" = "fedora" ] && echo "$$VERSION_ID"; else echo ""; fi) && echo "FEDORA_VERSION: $$FEDORA_VERSION" && echo -n $$FEDORA_VERSION > FEDORA_VERSION && sed -i "s/^- Fedora .*/- Fedora $$FEDORA_VERSION/g" README.md
