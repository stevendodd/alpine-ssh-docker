#!/bin/ash

echo Starting crond and adding logrotate job
crond
(crontab -l 2>/dev/null; echo "*/15 * * * * logrotate /etc/logrotate.conf --debug") | crontab -
crontab -l

echo
echo Adding firewall rules
/usr/local/bin/firewall-rules.sh

echo
echo Starting sshd and logger
/usr/local/bin/ssh_logger.sh &
/usr/sbin/sshd -D -E /etc/ssh/ssh_fifo &

echo
echo Starting fail2ban
fail2ban-client start
fail2ban-client status sshd
fail2ban-regex -d "\[%Y-%m-%d %H:%M:%S\] " /var/log/auth.log /etc/fail2ban/filter.d/alpine-sshd.local 

/bin/sh