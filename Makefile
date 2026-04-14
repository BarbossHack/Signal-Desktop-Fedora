.PHONY=build install clean update standalone

SIGNAL_VERSION := v8.6.1
FEDORA_VERSION := 43

PATCH_FILE := "Signal-Desktop.patch"
ARCH := $(if $(filter aarch64,$(shell uname -m)),arm64v8,amd64)
NODE_VERSION := $(shell curl -s "https://raw.githubusercontent.com/signalapp/Signal-Desktop/refs/tags/v$$(echo "$(SIGNAL_VERSION)" | tr -d vV)/.nvmrc")
ENGINE := podman

all: build

build: clean
	@echo "SIGNAL_VERSION: $(SIGNAL_VERSION)"
	@echo "FEDORA_VERSION: $(FEDORA_VERSION)"
	@echo "ARCH: $(ARCH)"
	@echo "PATCH_FILE: $(PATCH_FILE)"
	@mkdir -p output
	@$(ENGINE) build --build-arg=ARCH=$(ARCH) --build-arg=FEDORA_VERSION=$(FEDORA_VERSION) --build-arg=PATCH_FILE=./patch/$(PATCH_FILE) --build-arg NODE_VERSION=$(NODE_VERSION) -t signal-desktop-rpm:latest .
	@$(ENGINE) run --rm -e SIGNAL_VERSION=$$(echo "$(SIGNAL_VERSION)" | tr -d vV) -v $$PWD/output:/output:Z signal-desktop-rpm:latest

standalone:
	@make --no-print-directory PATCH_FILE=Signal-Desktop-standalone.patch

install:
	@-pkill --signal SIGHUP -x signal-desktop >/dev/null 2>/dev/null
	@sleep 2
	@-pkill --signal SIGKILL -x signal-desktop >/dev/null 2>/dev/null
	@sudo dnf install -y output/*.rpm
	@sudo sed -i 's|Exec=/opt/Signal/signal-desktop.*|Exec=/opt/Signal/signal-desktop --use-tray-icon %U|g' /usr/share/applications/signal-desktop.desktop
	@sudo sed -i 's|StartupWMClass=Signal|StartupWMClass=signal|g' /usr/share/applications/signal-desktop.desktop

clean:
	@-$(ENGINE) unshare rm -rf ./output
	@-$(ENGINE) rm -f -t 0 signal-desktop-rpm 2>/dev/null

update:
	@SIGNAL_VERSION=$$(git ls-remote --tags https://github.com/signalapp/Signal-Desktop.git | awk -F/ '{print $$NF}' | grep -v '\-[a-z]' | grep -v '\^{}' | sort -V | tail -n 1 | tr -d vV) \
		&& echo "SIGNAL_VERSION: v$$SIGNAL_VERSION" \
		&& sed -i -E "s/[0-9]\.[0-9]{1,2}\.[0-9]/$$SIGNAL_VERSION/g" README.md \
		&& sed -i -E "s/^SIGNAL_VERSION=v?[0-9]\.[0-9]{1,2}\.[0-9]/SIGNAL_VERSION=v$$SIGNAL_VERSION/g" Makefile \
		&& sed -i -E "s/[0-9]\.[0-9]{1,2}\.[0-9]/$$SIGNAL_VERSION/g" .github/release-notes.md
	@FEDORA_VERSION=$$(if [ -f /etc/os-release ]; then . /etc/os-release && [ "$$ID" = "fedora" ] && echo "$$VERSION_ID"; else echo ""; fi) \
		&& echo "FEDORA_VERSION: $$FEDORA_VERSION" \
		&& sed -i "s/^- Fedora .*/- Fedora $$FEDORA_VERSION/g" README.md \
		&& sed -i "s/FEDORA_VERSION=.*/FEDORA_VERSION=$$FEDORA_VERSION/g" README.md \
		&& sed -i "s/^FEDORA_VERSION=.*/FEDORA_VERSION=$$FEDORA_VERSION/g" Makefile

release: update
	@git add .
	@git commit -m "$(SIGNAL_VERSION)"
	@git tag "$(SIGNAL_VERSION)"
	@git push
	@git push --tags
