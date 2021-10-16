FROM alpine

# add openssh, ssmtp and clean
RUN apk add --update openssh \
&& apk add ssmtp \
&& apk add iptables \
&& apk add fail2ban \
&& rm  -rf /tmp/* /var/cache/apk/* \
&& rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key \
&& mkfifo /etc/ssh/ssh_fifo

# add scripts and config
ADD src/scripts/docker-entrypoint.sh /usr/local/bin
ADD src/scripts/firewall-rules.sh /usr/local/bin
ADD src/scripts/start_sshd.sh /usr/local/bin
ADD src/scripts/ssh_logger.sh /usr/local/bin
ADD src/scripts/status.sh /usr/local/bin

ADD src/config/etc/ssh/sshd_config /etc/ssh
ADD src/config/ssmtp.conf /etc/ssmtp
ADD src/config/etc/motd /etc/motd
ADD src/config/etc/fail2ban/jail.local /etc/fail2ban 
ADD src/config/etc/fail2ban/filter.d/alpine-sshd.local /etc/fail2ban/filter.d
ADD src/config/etc/logrotate.d/auth /etc/logrotate.d

ADD users.tar /home
ADD src/scripts/addsshusers.sh /usr/local/bin
RUN addsshusers.sh

EXPOSE 22
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/local/bin/start_sshd.sh"]
