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

In the repository directory, download an iso file from [Ubuntu Server for ARM](https://ubuntu.com/download/server/arm). The following URL and file name of the iso file includes version may vary, so please check it at the download page.

```sh
curl -O 'https://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04.3-live-server-arm64.iso'
```

Then, mount downloaded iso file. You need to use `mount` instead of double-click the iso file. Extract Linux kernel (and ungzip,) and ramdisk.

```sh
# Create a mounting point.
mkdir -p ubuntu
# Attach and mount the iso file
hdiutil attach -nomount ubuntu-20.04.3-live-server-arm64.iso
mount -t cd9660 /dev/disk4 ubuntu # disk4 may vary depends on your environment, see output of `hdiutil`
# Copy linux kernel and ungzip
cp ubuntu/casper/vmlinuz vmlinux.gz
gzip -d vmlinux.gz
# Copy ramdisk
cp ubuntu/casper/initrd ./
# Unmount and detach the iso file
umount ubuntu
hdiutil detach disk4 # Same here.
# Remove the mounting point.
rm -rf ubuntu
```

Create a blank disk image, use following command.
Use [HolePunch](https://github.com/niw/HolePunch) to shrink actual disk usage, if it's preferred.

```sh
# Create a blank disk image.
dd if=/dev/zero of=disk.img bs=1g count=20
# Shrink actual disk usage (Optional.)
holepunch -p disk.img
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
  --image ubuntu-20.04.3-live-server-arm64.iso \
  --image disk.img
```

If you're using Intel Mac, you can use Ubuntu Desktop iso image and follow same steps as above for Apple Silicon Mac.
It is not necessary to run `gzip -d` to ungzip `vmlinuz` but you can use that bzImage file directly for `--vmlinux` argument.

### Serial device

TinyLinux connects standard input and output to the serial device.
To make it works on the terminal emulator, you may need to disable the line discipline used for the current terminal emulator
by using `stty raw` prior to use TinyLinux and restore state after using it.

For example, make a following shell script and use it instead.

```sh
#!/bin/sh
# Save current state
save_state=$(stty -g)
# Make it raw
stty raw
# Boot Linux
.build/TinyLinux.xcarchive/Products/usr/local/bin/TinyLinux ...
# Restore original state
stty "$save_state"
```

See `stty(3)` as well.
