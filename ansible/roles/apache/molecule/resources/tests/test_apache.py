"""Role testing files using testinfra."""


import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ["MOLECULE_INVENTORY_FILE"]
).get_hosts("all")


def test_httpd_is_installed(host):
    httpd = host.package("httpd")
    assert httpd.is_installed


def test_httpd_group(host):
    assert host.group("apache").exists


def test_httpd_user(host):
    assert host.user("apache").exists


def test_conf_directory(host):
    conf_directory = host.file("/etc/httpd")
    assert conf_directory.is_directory
    assert conf_directory.user == "root"
    assert conf_directory.group == "root"
    assert conf_directory.mode == 0o755


def test_httpd_directory(host):
    httpd_directory = host.file("/var/www")
    assert httpd_directory.is_directory
    assert httpd_directory.user == "root"
    assert httpd_directory.group == "root"
    assert httpd_directory.mode == 0o755


def test_httpd_init(host):
    httpd_init = host.file("/etc/systemd/system/multi-user.target.wants/httpd.service")
    assert httpd_init.is_symlink
    assert httpd_init.user == "root"
    assert httpd_init.group == "root"


def test_httpd_running_and_enabled(host):
    httpd = host.socket("tcp://:::80")
    assert httpd.is_listening
