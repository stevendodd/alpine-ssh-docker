#!/bin/ash

/usr/local/bin/firewall-rules.sh
/usr/local/bin/ssh_logger.sh &
/usr/sbin/sshd -D -E /etc/ssh/ssh_fifo &
/bin/sh
