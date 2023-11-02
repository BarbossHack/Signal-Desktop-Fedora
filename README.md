# Signal-Desktop-Fedora

A Dockerfile to build [Signal-Desktop](https://github.com/signalapp/Signal-Desktop) RPM package for Fedora.

Currently tested for :

- Fedora 38
- Signal-Desktop v6.37.0
- x86_64 and aarch64 architectures

## Requirements

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

Currently supported Fedora version is 38, but you can change it in `FEDORA_VERSION` file.

## Sources

<https://github.com/signalapp/Signal-Desktop/issues/4530#issuecomment-1079834967>

<https://github.com/michelamarie/fedora-signal/wiki/How-to-compile-Signal-Desktop-for-Fedora>
