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

### Install packages

$DNF_INSTALL $(cat /etc/dnf/protected.d/arcade-packages.conf)

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

### Enable SSH

systemctl enable sshd.service

### Enable greetd

systemctl enable greetd.service

### Create the arcade user

useradd --home-dir /home/arcade --no-create-home --shell /usr/bin/fish arcade

mkdir /home/arcade
chown arcade: /home/arcade
chmod o-rwx /home/arcade

chown -R arcade: /usr/share/arcade/home
chmod -R o-rwx /usr/share/arcade/home

### Install RetroArch

curl -O https://buildbot.libretro.com/nightly/linux/x86_64/RetroArch.7z

$DNF_INSTALL 7zip
7z x RetroArch.7z -o/tmp/RetroArch
dnf5 remove -y 7zip

rm RetroArch.7z

mv /tmp/RetroArch/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage /usr/share/arcade/RetroArch.AppImage
mv /tmp/RetroArch/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch /usr/share/arcade/home/.config/retroarch
rm -d \
  /tmp/RetroArch/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config \
  /tmp/RetroArch/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home \
  /tmp/RetroArch/RetroArch-Linux-x86_64 \
  /tmp/RetroArch

touch /usr/share/arcade/home/.config/retroarch/retroarch.cfg.overlay

### Prune packages

# The qemu entries here can be removed in the future if there is a use for it. Without a use, it is simply bloat.
# llvm-libs is unfortunately required by mesa-dri-drivers
dnf5 remove -y \
  ModemManager-glib \
  NetworkManager-cloud-setup \
  NetworkManager-tui \
  WALinuxAgent-udev \
  adcli \
  atheros-firmware \
  avahi \
  brcmfmac-firmware \
  cloud-utils-growpart \
  cracklib-dicts \
  flatpak \
  fwupd-plugin-modem-manager \
  intel-npu-firmware \
  libblockdev-crypto \
  libdnf5-plugin-expired-pgp-keys \
  libipa_hbac \
  libsmbclient \
  mt7xxx-firmware \
  nfs-client-utils \
  nfs-utils \
  nss \
  nss-altfiles \
  nss-softokn \
  nss-sysinit \
  nss-softokn-freebl \
  nvidia-gpu-firmware \
  nxpwireless-firmware \
  openssh-clients \
  p11-kit-server \
  python3-boto3 \
  python3-botocore \
  python3-libdnf5 \
  python3-s3transfer \
  qcom-wwan-firmware \
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
  realtek-firmware \
  samba-client-libs \
  samba-ndr-libs \
  sg3_utils \
  socat \
  sssd-ad \
  sssd-client \
  sssd-common \
  sssd-common-pac \
  sssd-ipa \
  sssd-krb5 \
  sssd-krb5-common \
  sssd-ldap \
  sssd-nfs-idmap \
  tiwilink-firmware \
  toolbox \
  udisks2 \
  vim-data \
  vim-minimal \
  volume_key-libs \
  zram-generator

dnf5 remove -y --setopt protected_packages= sudo sudo-python-plugin

### Regenerate initramfs (see https://docs.fedoraproject.org/ms/bootc/initramfs/)

$DNF_INSTALL binutils
kver=$(ls /usr/lib/modules); env DRACUT_NO_XATTR=1 dracut -vf /usr/lib/modules/$kver/initramfs.img "$kver"
dnf remove -y binutils

### Print leaf packages and package sizes

echo '=== leaf packages ==='
dnf5 leaves

echo '=== packages by size ==='
dnf repoquery -C --installed --qf "%{installsize} %{name}\n" | sort -n | numfmt --to=iec --format="%.2f"   

### Clean dnf cache

dnf5 clean all

### Remove dnf itself now that we're done with it

dnf5 remove -y --setopt protected_packages= dnf5 libdnf5
