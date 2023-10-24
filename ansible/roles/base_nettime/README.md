# Ansible Role: base_nettime

Installs [Chrony](https://chrony.tuxfamily.org/) for NTP time synchronization with servers and peers.
Uses keys for peer authentication, so you can see the NTP state of your subnet:

```python
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
==============================================================================
192.168.100.4               8   5  120m     +0.048      0.035   -166ms    35us
192.168.100.5              57  34  521m     +0.009      0.000   -113ms  6299ns
192.168.100.6              58  29  537m     -0.015      0.002    -58ms    49us
192.168.100.10              9   5  138m     +0.046      0.016   -113ms    24us
192.168.100.11             55  33  496m     +0.009      0.001   +567ms    15us
192.168.100.12             10   8  154m     +0.057      0.023   -135ms    36us
192.168.100.13              6   3   85m     +0.063      0.065   -233ms    37us
192.168.100.14             10   6  154m     +0.047      0.024   +527ms    41us
192.168.100.15              0   0     0     +0.000   2000.000     +0ns  4000ms
192.168.100.16             56  33  502m     -0.018      0.003    -33ms    56us
192.168.100.17             56  29  513m     -0.020      0.004   +398ms    82us
192.168.100.18             10   9  154m     +0.065      0.032  +1066ms    57us
192.168.100.19             48  28  474m     +0.002      0.001   +900ms    18us
192.168.100.20              9   6  137m     +0.052      0.026   +741ms    42us
```


## Requirements/Cautions
Centos 7+8 and/or Debian 10.

Generate a sha256 key if you want to sync peers and to be able to see if your peers are insync. 

```sh
chronyc keygen <nettime_keyid> SHA256 256"
```

Store the output as a var like this in a vault file:

```yaml
chrony_key: '1234 SHA256 HEX:DD4E59D2CAE16FFCEBF23D67201814A2FA63251E1B23A1AF3A99203121807C6C'
```

**NOTE**: firewalld or ufw will be installed if `manage_firewall` is true

## Dependencies

Ansible, no role dependencies, not python dependencies.

## Role variables


### unique integer to lookup key for peer authentication:
`nettime_keyid: 1234`

### NTP Pool region/tld.
`ntp_zone: .nl`
Best results are attained when using a local zone. NTP is served by a pool of
servers. `ntp_zone` is used in defaults/main.yml only.

[https://www.ntppool.org/zone/europe](https://www.ntppool.org/zone/europe)

### NTP time servers that you want to subscribe to:
`ntp_servers:`

### NTP time peers that you want to sync:
`ntp_peers:`

### Allow access from these subnets:
```
net_allow:
  - '192.168.0.0/16'
```
### deny access from these subnets:
net_deny: []


## Example playbook

```yaml
---
- hosts: all
  roles:
    - role: base_nettime
```

## License

MIT

## Reference:
  - [https://chrony.tuxfamily.org/](https://chrony.tuxfamily.org/)

## Author information

This role was created by Bas Meijer
