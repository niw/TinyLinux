TinyLinux
=========

Really a tiny minimum implementation of [Virtualization framework](https://developer.apple.com/documentation/virtualization) to boot Linux.

Prerequisites
-------------

- macOS Big Sur or later
- Xcode 12.3 or later

Usage
-----

Prepare Linux kernel and ramdisk file that works on each Intel or Apple Silicon architecture.

For example, if you're using Apple Silicon Mac and booting Ubuntu Server for ARM, follow the next steps.

First, clone this repository.

In the repository directory, download `ubuntu-20.04.1-live-server-arm64.iso` from [Ubuntu Server for ARM](https://ubuntu.com/download/server/arm).

```sh
curl -O 'https://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04.1-live-server-arm64.iso'
```

Then, mount downloaded iso file. You need to use `mount` instead of double-click the iso file. Extract Linux kernel (and ungzip,) and ramdisk.

```sh
mkdir -p ubuntu
# Attach and mount the iso file
hdiutil attach -nomount ubuntu-20.04.1-live-server-arm64.iso
mount -t cd9660 /dev/disk4 ubuntu # disk4 may vary depends on your environment, see output of `hdiutil`
# Copy linux kernel and ungzip
cp ubuntu/casper/vmlinuz vmlinux.gz
gzip -d vmlinux.gz
# Copy ramdisk
cp ubuntu/casper/initrd ./
# Unmount and detach the iso file
umount ubuntu
hdiutil detach disk4 # Same here.
```

Build TinyLinux then boot.

```sh
# Build TinyLinux
make
# Boot Linux
.build/TinyLinux.xcarchive/Products/usr/local/bin/TinyLinux \
  --vmlinux vmlinux \
  --initrd initrd \
  --commandline "console=hvc0 root=/dev/vda1" \
  --image ubuntu-20.04.1-live-server-arm64.iso
```
