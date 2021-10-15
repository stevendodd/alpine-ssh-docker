#!/bin/ash

echo processes
echo =================================
ps -ef

echo
echo fail2ban status
echo =================================
fail2ban-client status sshd

echo
echo Banned host count
echo =================================
awk '($(NF-1) = /Ban/){print $NF}' /var/log/fail2ban.log | sort | uniq -c | sort -n

echo
echo iptables
echo =================================
iptables -L

fail2ban-regex --print-all-missed -d "\[%Y-%m-%d %H:%M:%S\] " /var/log/auth.log /etc/fail2ban/filter.d/alpine-sshd.local