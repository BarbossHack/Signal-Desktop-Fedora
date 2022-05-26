.PHONY=build install clean

all: build

build: clean
	@mkdir -p output
	@podman build --build-arg=SIGNAL_VERSION=$$(cat ./SIGNAL_VERSION | tr -d vV) -t signal-desktop-rpm:latest .
	@podman create --name signal-desktop-rpm signal-desktop-rpm:latest
	@podman cp signal-desktop-rpm:/root/Signal-Desktop/release/signal-desktop-$$(cat ./SIGNAL_VERSION | tr -d vV).x86_64.rpm ./output

install:
	@-pkill -x signal-desktop 2>/dev/null
	@sudo rpm -Uvh output/signal-desktop-$$(cat ./SIGNAL_VERSION | tr -d vV).x86_64.rpm
	@sudo sed -i 's|Exec=/opt/Signal/signal-desktop.*|Exec=/opt/Signal/signal-desktop --use-tray-icon %U|g' /usr/share/applications/signal-desktop.desktop

clean:
	@podman unshare rm -rf ./output
	@-podman rm -f signal-desktop-rpm 2>/dev/null
