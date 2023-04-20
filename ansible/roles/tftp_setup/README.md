# tftp-setup

Installs a TFTP server for PXE boot. Also installs the TFTP client package for testing.

## Testing ##
cd to this role's directory and run:
```
sudo -v
molecule test -s localhost
molecule test -s labvm
```

## Role variables ##

- `config_destination`: Where the TFTP config override snippet for systemd should be installed (Default: `/etc/systemd/system/tftp.service.d`)
- `tftpboot_folder`: TFTP home folder, where files should be offered via tftp (Default: `/var/lib/tftpboot`)
- `TFTP_user`: Under which user the TFTP server should run when transferring files (Default: tftpd) __Note: this name is also used to name the group assumed by the TFTP server.__
- `TFTP_group_members`: The list of users who should be made member of the group assumed by the TFTP server. (Default: None)
- `start_on_boot`: (Default: true)
- `enable_permanent_firewall`: (Default: true)

## Role dependencies ##

List dependencies on other roles here

## Examples ##

```yaml
roles:
    - role: tftp-setup
```
