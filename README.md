# Signal-Desktop-Fedora

A Dockerfile to build [Signal-Desktop](https://github.com/signalapp/Signal-Desktop) RPM package for Fedora !

Last versions (can be configured) :

- Fedora 37
- Signal-Desktop v6.11.0

## Requirements

Podman and make are the only requirements

```bash
sudo dnf install -y podman make
```

## Usage

```bash
make
make install
```

### Custom patch

You can apply a custom patch file with PATCH_FILE argument in the make command line.

For example, you can use `Signal-Desktop-persistent-messages.patch` which will ignore all kinds of message deletion (`expiration` and `delete for everyone`).

```bash
make PATCH_FILE=Signal-Desktop-persistent-messages.patch
make install
```

## Signal version

I will try to keep this script up to date, but you can set the Signal-Desktop version in `SIGNAL_VERSION` file.

It should be a valid `tag` from <https://github.com/signalapp/Signal-Desktop/tags>

## Fedora version

Current supported Fedora version is 37, but you can change the version in `FEDORA_VERSION` file.

## Credits

Thanks to [yea-hung](https://github.com/signalapp/Signal-Desktop/issues/4530#issuecomment-1079834967) and [michelamarie](https://github.com/michelamarie/fedora-signal/wiki/How-to-compile-Signal-Desktop-for-Fedora).

[Signal-Desktop](https://github.com/signalapp/Signal-Desktop)
