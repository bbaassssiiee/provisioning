#!/bin/bash -e

export GPG_KEY=https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux
echo "downloading ${GPG_KEY}"
curl -s --tlsv1.2 -O ${GPG_KEY}
gpg --import RPM-GPG-KEY-AlmaLinux
curl -s --tlsv1.2 -O https://repo.almalinux.org/almalinux/8.7/isos/x86_64/CHECKSUM
gpg --verify CHECKSUM
SHA256=$(cat CHECKSUM | grep -E 'SHA256.*AlmaLinux-8.7-x86_64-dvd.iso'|cut -d= -f2|sed 's/^ //')
echo "DVD checksum   default = \"sha256:${SHA256}"\"
echo -n "PKR checksum "
grep ${SHA256} variables.auto.pkrvars.hcl || exit 1