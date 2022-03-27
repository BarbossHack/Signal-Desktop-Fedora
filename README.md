# Signal-Desktop-RPM

A Dockerfile to build [Signal-Desktop](https://github.com/signalapp/Signal-Desktop) RPM package for Fedora 35 !

## Usage

```bash
make
make install
```

## Signal version

You can set the Signal-Desktop version in `SIGNAL_VERSION` file.

Should be a valid `tag` without `v` https://github.com/signalapp/Signal-Desktop/tags

## Credits

Thanks to [yea-hung](https://github.com/signalapp/Signal-Desktop/issues/4530#issuecomment-1079834967) and [michelamarie](https://github.com/michelamarie/fedora-signal/wiki/How-to-compile-Signal-Desktop-for-Fedora).

[Signal-Desktop](https://github.com/signalapp/Signal-Desktop)