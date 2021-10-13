#!/bin/ash

touch /var/log/auth.log
touch /var/log/fail2ban.log
chmod ugo+r /var/log/auth.log
chmod ugo+r /var/log/fail2ban.log
(crontab -l 2>/dev/null; echo "*/55 23 * * * logrotate /etc/logrotate.conf --debug") | crontab -
logrotate /etc/logrotate.conf --debug

/usr/local/bin/firewall-rules.sh
/usr/local/bin/ssh_logger.sh &
/usr/sbin/sshd -D -E /etc/ssh/ssh_fifo &
fail2ban-client start
fail2ban-client status sshd
fail2ban-regex -d "\[%Y-%m-%d %H:%M:%S\] " /var/log/auth.log /etc/fail2ban/filter.d/alpine-sshd.local 
/bin/sh
