bootc --source-imgref containers-storage:ghcr.io/carletoncomputersciencesociety/arcade-machine:latest --target-imgref ghcr.io/carletoncomputersciencesociety/arcade-machine:latest

cmdline

%pre --erroronfail --interpreter=/bin/bash

# Output to TTY
exec &>>/dev/tty1

declare -a target_disks

for dev in /sys/block/*; do
    name=$(basename "$dev")
    # Skip partitions (whole disks only)
    [ -f "$dev/partition" ] && continue
    # Skip removable media (USB installer, CD/DVD)
    removable=$(cat "$dev/removable" 2>/dev/null)
    [ "$removable" -eq 1 ] && continue
    target_disks+=("$name")
done

count=${#target_disks[@]}

if [ "$count" -eq 0 ]; then
    echo "ERROR: No non-removable disk found. Aborting." >&2
    exit 1
elif [ "$count" -gt 1 ]; then
    echo "ERROR: Multiple non-removable disks found: ${target_disks[*]}" >&2
    exit 1
fi

TARGET_DISK="${target_disks[0]}"
echo "Will install to $TARGET_DISK"

cat > /tmp/disk-include <<EOF
ignoredisk --only-use=$TARGET_DISK
EOF

read -p "Press Enter to begin installation (or Ctrl+C to abort): " _

%end

%include /tmp/disk-include
zerombr
clearpart --all --initlabel
autopart --type=plain --fstype=xfs --nohome --noswap

keyboard --vckeymap=us --xlayouts=us
lang en_CA.UTF-8
rootpw --lock

%packages
@core
%end

reboot
