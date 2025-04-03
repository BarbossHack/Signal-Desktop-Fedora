# Signal-Desktop-Fedora

[Signal-Desktop](https://github.com/signalapp/Signal-Desktop) RPM for Fedora.

Currently tested for :

- Fedora 41
- Signal-Desktop v7.49.0
- x86_64 and aarch64 architectures

## How to install

Download the latest pre-compiled RPM from [GitHub Releases](https://github.com/BarbossHack/Signal-Desktop-Fedora/releases) and install it using the following command:

```bash
sudo rpm -Uvh --force signal-desktop-*.rpm
```

These RPMs have been built using [GitHub Actions](.github/workflows/build.yml). You can verify their authenticity with the following command:

```bash
gh attestation verify --owner BarbossHack --predicate-type "https://example.com/predicate/v1" signal-desktop-*.rpm
```

## Build it yourself

### Requirements

```bash
sudo dnf install -y podman make
```

### Build and install

```bash
make
make install
```

### Custom patch

You can apply a custom patch file using `PATCH_FILE` argument in the `make` command.

For example, you can use `Signal-Desktop-persistent-messages.patch` which will prevents all types of message deletion (`expiration` and `delete for everyone`).

```bash
make PATCH_FILE=Signal-Desktop-persistent-messages.patch
make install
```

### Signal version

You can set the Signal-Desktop version in the `SIGNAL_VERSION` file (e.g., by running `make update`).

It should correspond to a valid tag from [here](https://github.com/signalapp/Signal-Desktop/tags).

### Fedora version

You can modify the version in the `FEDORA_VERSION` file.

## Credits

Based on the Signal-Desktop [reproducible builds](https://github.com/signalapp/Signal-Desktop/tree/main/reproducible-builds).
