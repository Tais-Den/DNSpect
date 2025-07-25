#!/usr/bin/env bash
set -e

# Verify critical tools exist and print their versions

dig -v

dnsrecon -h >/dev/null

echo "dnsrecon available"

amass -version

zonemaster-cli --version

dmarc-cat -h | head -n 1

despf.sh -h | head -n 1
