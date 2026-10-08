#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

dnf5 install -y alacritty fish greetd helix niri

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

### Configure greeter

# enable if switching to fedora-silverblue base image
# systemctl disable gdm.service
systemctl enable greetd.service

useradd --home-dir / --no-create-home --system --shell /bin/nologin greeter

### Create the arcade user

useradd --create-home --shell /usr/bin/fish arcade

### Install RetroArch

curl -O https://buildbot.libretro.com/nightly/linux/x86_64/RetroArch.7z

dnf5 install -y p7zip
7z x RetroArch.7z -o/opt/RetroArch
dnf5 remove p7zip

mv /opt/RetroArch/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage /opt/RetroArch/RetroArch.AppImage
mv /opt/RetroArch/RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home /var/arcade/RetroArch/RetroArch.AppImage.home
rm -d /opt/RetroArch/RetroArch-Linux-x86_64

ln -s /var/arcade/RetroArch/RetroArch.AppImage.home /opt/RetroArch/RetroArch.AppImage.home
# TODO: any files we want to be immutable and update with the image should go under /opt and be symlinked in
# TODO: generate two variants of RetroArch config file under /opt, with and without kiosk mode, and link in so it can be toggled by ujust
#       alternatively, produce a template of the config that can be rendered to the live config under /var
