#!/bin/sh

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

#prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi

chown root:root /var/log

touch /var/log/auth.log
touch /var/log/fail2ban.log
touch /var/log/startup.log

chmod ugo+r /var/log/auth.log
chmod ugo+r /var/log/fail2ban.log
chmod ugo+r /var/log/startup.log

exec "$@" > /var/log/startup.log

