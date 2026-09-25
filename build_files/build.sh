#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

dnf5 install -y fish greetd helix niri

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

### Prune services

systemctl disable ModemManager.service avahi-daemon.service avahi-daemon.socket

### Configure greeter

systemctl disable gdm.service
systemctl enable greetd.service
