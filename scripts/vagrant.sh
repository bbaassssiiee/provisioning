#!/bin/bash
/usr/sbin/groupadd vagrant
/usr/sbin/useradd vagrant -g vagrant -G wheel -d /home/vagrant -c "vagrant"
echo "vagrant" | passwd --stdin vagrant
echo "installing ssh-key for vagrant"
(cd /home/vagrant && mkdir -pm 700 .ssh)

# This ssh is replaced in 'vagrant up' if the Vagrantfile has `config.ssh.insert_key = true``
cat > /home/vagrant/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
restorecon -R -v /home/vagrant/.ssh
# allow vagrant user to run everything without a password
echo 'vagrant     ALL=(ALL)     NOPASSWD: ALL' >> /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant