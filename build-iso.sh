#!/bin/sh

#this script must be run as root

#create working and out directories
mkdir -p out temp/{work/iso,rootfs}

#bind mount temporary rootfs on itself
mount --bind temp/rootfs temp/rootfs

#install packages to target rootfs
pacstrap -c temp/rootfs/ $(cat package_list)

#extract rootfs_skel
unsquashfs -f -d temp/rootfs rootfs_skel.sfs

arch-chroot temp/rootfs <<EOT
rm -rf /boot/initramfs-linux*
echo -e "rdp\nrdp" | passwd
useradd rdp -m
passwd -d rdp
systemctl enable dhcpcd
EOT

umount -R temp/rootfs

#create squashed rootfs
mksquashfs temp/rootfs/ temp/work/iso/rootfs.sfs

#make archiso
mkarchiso -v -w temp/work/ -o out/ releng/

#delete temporary directories
rm -rf temp/
