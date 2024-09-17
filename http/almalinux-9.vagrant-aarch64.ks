# AlmaLinux OS 9 kickstart file for Vagrant boxes on AArch64

url --url https://repo.almalinux.org/almalinux/9/BaseOS/aarch64/kickstart/
repo --name=BaseOS --baseurl=http://repo.rnd.ims.co.at/pulp/repos/alma/9.4-20240827/BaseOS/x86_64/os/
repo --name=AppStream --baseurl=http://repo.rnd.ims.co.at/pulp/repos/alma/9.4-20240827/AppStream/x86_64/os/

text
skipx
eula --agreed
firstboot --disabled
lang C.UTF-8
keyboard us
timezone UTC --utc
network --bootproto=dhcp
firewall --disabled
services --enabled=sshd
selinux --enforcing

bootloader --timeout=0 --location=mbr --append="console=tty0 console=ttyS0,115200n8 no_timer_check net.ifnames=0"

zerombr
clearpart --all --initlabel
part /boot/efi --fstype=efi --size=200
part /boot --fstype=xfs --size=1024
part / --fstype=xfs --grow

rootpw root
user --name=root --plaintext --password root
reboot --eject

%packages --inst-langs=en
@core
bzip2
dracut-config-generic
tar
usermode
-biosdevname
-dnf-plugin-spacewalk
-dracut-config-rescue
-iprutils
-iwl*-firmware
-langpacks-*
-mdadm
-open-vm-tools
-plymouth
-rhn*
%end

# disable kdump service
%addon com_redhat_kdump --disable
%end

%post --erroronfail

# allow root user to run everything without a password
echo "root     ALL=(ALL)     NOPASSWD: ALL" >> /etc/sudoers.d/root

# see Vagrant documentation (https://docs.vagrantup.com/v2/boxes/base.html)
# for details about the requiretty.
sed -i "s/^.*requiretty/# Defaults requiretty/" /etc/sudoers

# permit root login via SSH with password authetication
echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/01-permitrootlogin.conf

%end
