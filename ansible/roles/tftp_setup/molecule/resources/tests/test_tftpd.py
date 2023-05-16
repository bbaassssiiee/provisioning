"""Role testing files using testinfra."""


import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ["MOLECULE_INVENTORY_FILE"]
).get_hosts("all")


def test_tftpd_is_installed(host):
    tftpd = host.package("tftp-server")
    assert tftpd.is_installed


def test_tftpd_group(host):
    assert host.group("tftpd").exists


def test_tftpd_user(host):
    assert host.user("tftpd").exists


def test_tftp_directory(host):
    tftp_directory = host.file("/var/lib/tftpboot")
    assert tftp_directory.is_directory
    assert tftp_directory.user == "tftpd"
    assert tftp_directory.group == "tftpd"
    assert tftp_directory.mode == 0o2775


def test_tftpd_config_dir(host):
    tftpd_config_dir = host.file("/etc/systemd/system/tftp.service.d")
    assert tftpd_config_dir.is_directory
    assert tftpd_config_dir.user == "root"
    assert tftpd_config_dir.group == "root"
    assert tftpd_config_dir.mode == 0o755


def test_tftpd_config_file(host):
    tftpd_cfg = host.file("/etc/systemd/system/tftp.service.d/override.conf")
    assert tftpd_cfg.user == "root"
    assert tftpd_cfg.group == "root"
    assert tftpd_cfg.mode == 0o644


def test_tftpd_running_and_enabled(host):
    tftpd = host.socket("udp://:::69")
    assert tftpd.is_listening
