# Aarch64

> Run aarch64 image:

```bash
curl -L https://mirror.in2p3.fr/pub/fedora/linux/releases/42/Server/aarch64/images/Fedora-Server-Host-Generic-42-1.1.aarch64.raw.xz -o img.raw.xz

xz --decompress img.raw.xz
truncate -r img.raw fedora.raw
truncate -s +10G fedora.raw
virt-resize --expand /dev/sda3 img.raw fedora.raw
rm -f img.raw

qemu-system-aarch64 -nographic -m 8096M -cpu cortex-a57 -smp 4 \
    -netdev user,id=unet -device virtio-net-pci,netdev=unet \
    -drive file=fedora.raw -M virt \
    -bios /usr/share/edk2/aarch64/QEMU_EFI.fd

# Set root password when asked.
```

> Once launched, run:

```bash
lvextend --extents +100%FREE /dev/systemVG/LVRoot
xfs_growfs /
dnf install -y git make podman
useradd user
loginctl enable-linger user
su -l user
git clone https://github.com/BarbossHack/Signal-Desktop-Fedora
cd Signal-Desktop-Fedora
make
```
