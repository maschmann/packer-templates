#!/bin/bash

set -e
set -x

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

echo 'archlinux' > /etc/hostname

sed -i -e 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

mkinitcpio -p linux

echo -e 'vagrant\nvagrant' | passwd
useradd -m -U vagrant
echo -e 'vagrant\nvagrant' | passwd vagrant
cat <<EOF > /etc/sudoers.d/vagrant
Defaults:vagrant !requiretty
vagrant ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/vagrant

mkdir -p /etc/systemd/network
ln -sf /dev/null /etc/systemd/network/99-default.link

systemctl enable sshd
systemctl enable dhcpcd@eth0

syslinux-install_update -i -a -m
sed -i \
  -e 's,\(APPEND root=\).*,\1/dev/sda2,' \
  -e 's/TIMEOUT.*/TIMEOUT 10/' \
  /boot/syslinux/syslinux.cfg
