# apache

Ansible-role to install the Apache webserver with directory browsing enabled.

Intended for the kickstart environment.

## Testing ##

cd to this role's directory and run:

```bash
sudo true
molecule test -s localhost
```


### Role variables

`apache_packages`: A list of necessary packages for the apache webserver. Default packages:

- httpd
- mod\_ssl

### Examples

```yaml
- name: Install Apache web server
  hosts: all

  roles:
  - role: apache
```
