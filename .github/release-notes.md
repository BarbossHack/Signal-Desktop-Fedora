Install this prebuilt RPM using the following command:

```bash
sudo dnf install https://github.com/BarbossHack/Signal-Desktop-Fedora/releases/download/v7.67.0/signal-desktop-7.67.0.x86_64.rpm
```

This RPM has been built using [GitHub Actions](.github/workflows/build.yml). You can verify its authenticity with the following command:

```bash
gh attestation verify --owner BarbossHack --predicate-type "https://example.com/predicate/v1" signal-desktop-7.67.0.x86_64.rpm
```
