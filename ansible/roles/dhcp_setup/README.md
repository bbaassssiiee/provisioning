# DHCP-setup
This role installs and configures a DHCP server for PXE-boot.

## Testing ##
cd to this role's directory and run:
```
sudo -v
molecule test -s localhost
molecule test -s labvm
```
### Role variables
- `domain_name`: Domain name of DHCP server (Default: ".local")
- `config_destination`: (Default: /etc/dhcp/dhcpd.conf)
- `boot_filename`: (Default: "shimx64.efi")
- `start_on_boot`: (Default: true)
- `enable_permanent_firewall`: (Default: true)

### Examples
```yaml
roles:
- role: dhcp-setup
  vars:
    boot_filename: "shimx64.efi"
```
