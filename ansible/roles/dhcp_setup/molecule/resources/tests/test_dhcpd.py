"""Role testing files using testinfra."""


import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ["MOLECULE_INVENTORY_FILE"]
).get_hosts("all")


def test_dhcpd_is_installed(host):
    dhcpd = host.package("dhcp-server")
    assert dhcpd.is_installed


def test_dhcpd_config_dir(host):
    dhcpd_config_dir = host.file("/etc/dhcp")
    assert dhcpd_config_dir.is_directory
    assert dhcpd_config_dir.user == "root"
    assert dhcpd_config_dir.group == "root"
    assert dhcpd_config_dir.mode == 0o750

# requires root
#
# def test_dhcpd_config_file(host):
#    dhcpd_config = host.file("/etc/dhcp/dhcpd.conf")
#    assert dhcpd_config.user == "root"
#    assert dhcpd_config.group == "root"
#    assert dhcpd_config.mode == 0o644


def test_dhcpd_running_and_enabled(host):
    dhcpd_service = host.service("dhcpd")
    assert dhcpd_service.is_running
    assert dhcpd_service.is_enabled


def test_firewalld_running_and_enabled(host):
    firewalld = host.service("firewalld")
    assert firewalld.is_running
    assert firewalld.is_enabled


def test_dhcpd_socket(host):
    dhcpd_socket = host.socket("udp://0.0.0.0:67")
    assert dhcpd_socket.is_listening
