#!/bin/ash

echo Starting crond and adding logrotate job
echo ============================================
crond
(crontab -l 2>/dev/null; echo "15 * * * * logrotate /etc/logrotate.conf --debug") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * status.sh > /var/log/status") | crontab -

crontab -l

echo
echo Adding firewall rules
echo ============================================
/usr/local/bin/firewall-rules.sh

echo
echo Starting sshd and logger
echo ============================================
/usr/local/bin/ssh_logger.sh &
/usr/sbin/sshd -D -E /etc/ssh/ssh_fifo &

echo
echo Starting fail2ban
echo ============================================
fail2ban-client start
fail2ban-client status sshd
fail2ban-regex --print-all-missed --print-all-ignored -d "\[%Y-%m-%d %H:%M:%S\] " /var/log/auth.log alpine-sshd.local

/bin/sh