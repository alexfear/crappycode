#!/bin/bash
die() {
    echo >&2 "$@"
    exit 1
}

[[ $# -eq 1 ]] || die "1 parameter is required (host IP address), $# provided"
echo $1 | grep -E -q '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' || die "invalid host IP address"

host_ip=$1

[[ ! -f /tmp/ipmi_$host_ip.tmp ]] || ipmitool -U zabbix -H "$host_ip" -f /home/zabbix/.racpasswd -I lanplus -L user sdr > /tmp/ipmi_$host_ip.tmp
echo $?