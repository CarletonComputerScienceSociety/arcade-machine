FROM ghcr.io/carletoncomputersciencesociety/arcade-machine:latest

# these are necessary build tools. if you use a separate build container then
# these tools should be installed there
# TODO: not in final image
RUN dnf install -qy \
    grub2-efi-*-cdboot \
    dracut-live \
    implantisomd5 \
    xorrisofs \
    squashfs-tools
RUN dnf clean all
RUN mkdir -p /boot/efi && cp -ra /usr/lib/efi/*/*/EFI /boot/efi

# Include the dmsquash-live module in the initramfs
RUN cat <<EOF > /usr/lib/dracut/dracut.conf.d/40-iso.conf
compress="xz"
add_dracutmodules+=" qemu qemu-net livenet dmsquash-live "
early_microcode="no"
EOF

# Rebuild the initrd
RUN set -xe; kver=$(ls /usr/lib/modules); env DRACUT_NO_XATTR=1 dracut -vf /usr/lib/modules/$kver/initramfs.img "$kver"

# ---

# some configuration for our ISO

RUN mkdir -p /usr/lib/image-builder/bootc

RUN cat <<EOF > /usr/lib/image-builder/bootc/iso.yaml
label: "Fedora"
kernel_args:
  - console=ttyS0
grub2:
  timeout: 5
  entries:
    - name: "Arcade Machine OS"
      linux: \${kernelpath} \${root}
      initrd: \${initrdpath}
EOF

# Disable services that won't work on an iso
RUN systemctl mask bootloader-update.service
