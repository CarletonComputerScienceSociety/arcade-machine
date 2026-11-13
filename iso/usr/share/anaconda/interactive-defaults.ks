bootc --source-imgref containers-storage:ghcr.io/carletoncomputersciencesociety/arcade-machine:latest --target-imgref ghcr.io/carletoncomputersciencesociety/arcade-machine:latest

%pre --interpreter=/bin/bash
read -p "Press Enter to begin installation (or Ctrl+C to abort): " _
%end

cmdline

ignoredisk --only-use=sda
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
