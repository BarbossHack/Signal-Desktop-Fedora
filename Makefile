.PHONY=build install clean

SIGNAL_VERSION=$$(cat ./SIGNAL_VERSION | tr -d vV)
FEDORA_VERSION=$$(cat ./FEDORA_VERSION)

all: build

build: clean
	@mkdir -p output
	@podman build --build-arg=FEDORA_VERSION=$(FEDORA_VERSION) --build-arg=SIGNAL_VERSION=$(SIGNAL_VERSION) -t signal-desktop-rpm:latest .
	@podman create --name signal-desktop-rpm signal-desktop-rpm:latest
	@podman cp signal-desktop-rpm:/output/signal-desktop-$(SIGNAL_VERSION).x86_64.rpm ./output

install:
	@sudo rpm -Uvh --force output/signal-desktop-$(SIGNAL_VERSION).x86_64.rpm
	@sudo sed -i 's|Exec=/opt/Signal/signal-desktop.*|Exec=/opt/Signal/signal-desktop --use-tray-icon %U|g' /usr/share/applications/signal-desktop.desktop

clean:
	@podman unshare rm -rf ./output
	@-podman rm -f signal-desktop-rpm 2>/dev/null
