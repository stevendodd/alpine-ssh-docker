#!/bin/ash

echo date
echo =================================
date

echo
echo fscheck
echo =================================
LASTFSCK=`cat /var/log/fscheck`
FSCK=`find /bin /etc /lib /opt /sbin -exec ls -al {} \; | cksum`
echo "find /bin /etc /lib /opt /sbin -exec ls -al {} \; | cksum"
echo $LASTFSCK - Last fsck check
echo $FSCK - Now
echo $FSCK > /var/log/fscheck

echo
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

fail2ban-regex --print-all-missed --print-all-ignored -d "\[%Y-%m-%d %H:%M:%S\] " /var/log/auth.log alpine-sshd.local


if [ "$FSCK" != "$LASTFSCK" ]; then
  STATUS=`cat /var/log/status`
  CHANGED=`find / -mmin -5 -not -path "/sys/*" -not -path "/proc/*" | xargs ls -al`
  echo -e "To: ${EMAIL}\nSubject: Alpine SSH Alert\nFrom:${EMAIL}\n\n${STATUS}\n\nFiles changed:\n======================\n${CHANGED}\n" | sendmail -t
fi
