FROM alpine

ARG USER
ARG PASSWORD

# add openssh, ssmtp and clean
RUN apk add --update openssh \
&& apk add ssmtp \
&& apk add iptables \
&& apk add fail2ban \
&& rm  -rf /tmp/* /var/cache/apk/*

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

#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

RUN adduser -h /home/${USER} -D -s /bin/sh ${USER} \
&& echo "${USER}:${PASSWORD}" | chpasswd
ADD --chown=${USER}:${USER} src/config/authorized_keys /home/${USER}/.ssh/
RUN chmod 700 /home/${USER}/.ssh \
&& chmod 600 /home/${USER}/.ssh/authorized_keys

RUN mkfifo /etc/ssh/ssh_fifo

EXPOSE 22
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/local/bin/start_sshd.sh"]
