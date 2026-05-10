#! bin/bash

# we are creating 50 GB root disk, but only 20 GB is partitioned
# remaining 30 GB we need to extened 
growpart /dev/nvme0n1 4
lvextend -r -L +30G /dev/mapper/RootVG-homeVol
xfs_growfs /home


install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform