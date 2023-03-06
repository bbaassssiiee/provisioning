#!/bin/bash -x

rm -rf /dev/.udev/
if [ -f /etc/sysconfig/network-scripts/ifcfg-eth0 ] ; then
    sed -i "/^HWADDR/d" /etc/sysconfig/network-scripts/ifcfg-eth0
    sed -i "/^UUID/d" /etc/sysconfig/network-scripts/ifcfg-eth0
fi

echo 'Clean up yum cache'
yum clean all

# minimize disk usage

echo "Clear core files"
rm -f /core*

echo "Remove temporary files used to build box"
rm -rf /tmp/*

echo "Rebuild RPM DB"
rpmdb --rebuilddb
rm -f /var/lib/rpm/__db*

find /var/log/ -name "./*.log" -exec rm -f {} \;
rm -f /var/log/anaconda.syslog
rm -f /var/log/dmesg.old
truncate -s0 /var/log/lastlog
truncate -s0 /var/log/wtmp
truncate -s0 /var/log/messages
truncate -s0 /var/log/lastlog

rm -rf /tmp/*.gz /tmp/packer-provisioner-ansible-local
history -c

case "$PACKER_BUILDER_TYPE" in

  virtualbox-iso)

      # Zero out the rest of the free space using dd, then delete the written file.
      dd if=/dev/zero of=/EMPTY bs=1M
      rm -f /EMPTY

      # WORKAROUND: remove myself: https://github.com/mitchellh/packer/issues/1536
      rm -f /tmp/script.sh

      # Add `sync` so Packer doesn't quit too early, before the large file is deleted.
      sync
      ;;
  *)
      echo "Done for ${PACKER_BUILDER_TYPE}"
      ;;

esac
