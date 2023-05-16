#!/bin/bash

# Run ssh-audit
/usr/local/bin/ssh-audit -n -l warn localhost

# Install scanner
dnf -y install openscap-scanner scap-security-guide

# Run scanner
oscap xccdf eval --report /tmp/report.html --profile cis \
  --fetch-remote-resources \
  /usr/share/xml/scap/ssg/content/ssg-almalinux8-ds.xml \
  | grep -B2 fail

chmod 644 /tmp/report.html