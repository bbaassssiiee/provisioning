#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR=/home/vagrant

case "$PACKER_BUILDER_TYPE" in

    virtualbox-iso|virtualbox-ovf)
    useradd vboxadd
    mkdir -p /tmp/vbox /run/vboxadd
    chown vboxadd /run/vboxadd
    chmod 700 /run/vboxadd
    mount -o loop $HOME_DIR/VBoxGuestAdditions.iso /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
            "For more read https://www.virtualbox.org/ticket/12479";
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;

    ;;

*)
    echo "No guest additions implemented for ${PACKER_BUILDER_TYPE}"
    ;;

esac
