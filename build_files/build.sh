#!/bin/bash

set -ouex pipefail

DNF_INSTALL="dnf5 install -y --nodocs --setopt install_weak_deps=0"

# Remove symlink to /var/home
# We can link anything that should be mutable manually
rm /home

mkdir /home

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Fix permissions on SSH authorized keys files
chmod 755 /etc/ssh/authorized_keys
chmod 644 /etc/ssh/authorized_keys/root

# Regenerate initramfs (see https://docs.fedoraproject.org/ms/bootc/initramfs/)
kver=$(ls /usr/lib/modules); env DRACUT_NO_XATTR=1 dracut -vf /usr/lib/modules/$kver/initramfs.img "$kver"

### Prune packages

# The qemu exclusion here can be removed in the future if there is a use for it. Without a use, it is simply bloat.
dnf remove -y \
  NetworkManager-cloud-setup \
  NetworkManager-tui \
  WALinuxAgent-udev \
  libipa_hbac \
  libsmbclient \
  llvm-libs \
  nfs-utils \
  nss-altfiles \
  nvidia-gpu-firmware \
  openssh-clients \
  p11-kit-server \
  python3-libdnf5 \
  qemu-user-static \
  qemu-user-static-alpha \
  qemu-user-static-hexagon \
  qemu-user-static-hppa \
  qemu-user-static-loongarch64 \
  qemu-user-static-m68k \
  qemu-user-static-microblaze \
  qemu-user-static-mips \
  qemu-user-static-or1k \
  qemu-user-static-ppc \
  qemu-user-static-riscv \
  qemu-user-static-s390x \
  qemu-user-static-sh4 \
  qemu-user-static-sparc \
  qemu-user-static-xtensa \
  sg3_utils \
  socat \
  sssd-ad \
  sssd-common \
  sssd-common-pac \
  sssd-ipa \
  sssd-krb5 \
  sssd-krb5-common \
  sssd-ldap \
  toolbox \
  vim-data \
  vim-minimal \
  zram-generator

dnf remove -y --setopt protected_packages= sudo sudo-python-plugin

### Install packages

$DNF_INSTALL alacritty fish greetd helix niri waybar

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

### Prune services

# fedora-bootc base image does not come with ModemManager?
# systemctl disable ModemManager.service avahi-daemon.service avahi-daemon.socket
systemctl disable avahi-daemon.service avahi-daemon.socket

### Enable SSH

systemctl enable sshd.service

### Configure greeter

# enable if switching to fedora-silverblue base image
# systemctl disable gdm.service
systemctl enable greetd.service

useradd --home-dir / --no-create-home --system --shell /bin/nologin greeter

### Create the arcade user

useradd --home-dir /home/arcade --no-create-home --shell /usr/bin/fish arcade

mkdir /home/arcade
chown arcade: /home/arcade
chmod o-rwx /home/arcade

### Install RetroArch

curl -O https://buildbot.libretro.com/nightly/linux/x86_64/RetroArch.7z

$DNF_INSTALL 7zip-standalone
7z x RetroArch.7z -o/opt/RetroArch
dnf5 remove -y 7zip-standalone

rm RetroArch.7z

mv /opt/RetroArch/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage /opt/RetroArch/RetroArch.AppImage
mv /opt/RetroArch/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home /opt/RetroArch/RetroArch.AppImage.home
rm -d /opt/RetroArch/RetroArch-Linux-x86_64

### Print leaf packages

dnf5 leaves

### Clean dnf cache

dnf5 clean all

### Remove dnf itself now that we're done with it

dnf5 remove -y --setopt protected_packages= dnf5
