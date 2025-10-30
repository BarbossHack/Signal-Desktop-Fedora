# Signal-Desktop-Fedora

[Signal Desktop](https://github.com/signalapp/Signal-Desktop) RPM for Fedora.

Currently tested for :

- Fedora 42
- Signal Desktop v7.77.1
- x86_64 and aarch64 architectures

## How to install

Install the latest prebuilt RPM from [GitHub Releases](https://github.com/BarbossHack/Signal-Desktop-Fedora/releases) using the following command:

```bash
sudo dnf install "https://github.com/BarbossHack/Signal-Desktop-Fedora/releases/download/v7.77.1/signal-desktop-7.77.1.x86_64.rpm"
```

## Build it yourself

```bash
make
make install
```

## Custom builds

### Change versions

You can change the Signal Desktop or Fedora version by using the following parameters:

```bash
make SIGNAL_VERSION=7.77.1 FEDORA_VERSION=42
make install
```

`SIGNAL_VERSION` should correspond to a valid tag from [here](https://github.com/signalapp/Signal-Desktop/tags).

### Standalone primary device

You can create a new account directly in Signal Desktop, but you'll need to build the `standalone` version.

```bash
make standalone
make install
```

Next, open Signal Desktop, and on the QR code screen, go to the File menu and select `Set Up as Standalone Device`, which goes through the registration process like you would on a phone.

### Custom patch

You can apply a custom patch file using `PATCH_FILE` argument in the `make` command.

For example, you can use `Signal-Desktop-persistent-messages.patch` which will prevents all types of message deletion (`expiration` and `delete for everyone`).

```bash
make PATCH_FILE=Signal-Desktop-persistent-messages.patch
make install
```

## Credits

Based on the Signal Desktop [reproducible builds](https://github.com/signalapp/Signal-Desktop/tree/main/reproducible-builds).
