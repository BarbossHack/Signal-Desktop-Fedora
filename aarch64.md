# Aarch64

> Run aarch64 image

```bash
curl -L https://download.fedoraproject.org/pub/fedora/linux/releases/40/Server/aarch64/images/Fedora-Server-40-1.14.aarch64.raw.xz -o f40.raw.xz

xz --decompress f40.raw.xz

qemu-system-aarch64 -nographic -m 8096M -cpu cortex-a57 -smp 4 \
 -netdev user,id=unet -device virtio-net-pci,netdev=unet \
    -drive file=f40.raw -M virt \
    -bios /usr/share/edk2/aarch64/QEMU_EFI.fd
```

> Once launched, run :

```bash
dnf install -y git make podman
useradd user
loginctl enable-linger user
su -l user
git clone https://github.com/BarbossHack/Signal-Desktop-Fedora
cd Signal-Desktop-Fedora
make
```

## Credits

<https://www.redhat.com/sysadmin/vm-arm64-fedora>
