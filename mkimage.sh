#!/bin/sh

source ./clean.sh
mkdir -p build/image

if [ -f setEnvironment.sh ]
then
  source ./setEnvironment.sh
else
    USER=mysshuser
    PASSWORD=mysshusers-password
    SSHKEY="ssh-rsa AAAAB3N..."
    SSHKEYB="ssh-rsa AAAAB3N..."
    EMAIL=myemail@outlook.com
    EMAILPASSWORD="myemail-password"
    SMTPSERVER=smtp-mail.outlook.com:587
    EMAILDOMAIN=outlook.com
    DOCKERREGISTRY=mydockerregistry:5000
    CONTAINERHOST=mycontainerhost-ip
    CONTAINERHOSTNETWORK=qnet-static-eth0-XXXX
    CONTAINERMACADDRESS=XX:XX:XX:XX:XX:XX
    CONTAINERIP=192.168.0.XX
fi

cat > build/docker-compose.yaml <<EOF
 version: '3'
 services:
    alpine-ssh:
        container_name: alpine-ssh
        image: $DOCKERREGISTRY/stevendodd/alpine-sshd
        restart: unless-stopped
        volumes:
        - /etc/timezone:/etc/timezone:ro
        - /etc/localtime:/etc/localtime:ro
        - /share/logs/alpine-ssh:/var/log
        cap_add:
        - NET_ADMIN
        tty: true
        hostname: alpinessh
        mac_address: $CONTAINERMACADDRESS
        networks:
            $CONTAINERHOSTNETWORK:
                ipv4_address: $CONTAINERIP

 networks:
    $CONTAINERHOSTNETWORK:
        external: true
EOF

cat > src/config/ssmtp.conf <<EOF
root=$EMAIL
mailhub=$SMTPSERVER
FromLineOverride=YES
rewriteDomain=$EMAILDOMAIN
AuthUser=$EMAIL
AuthPass=$EMAILPASSWORD
UseSTARTTLS=YES
hostname=alpine-ssh
EOF

cat > src/scripts/firewall-rules.sh <<EOF
#!/bin/ash

iptables -A OUTPUT -p tcp --sport ssh -s $CONTAINERHOST -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -d $CONTAINERHOST -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport ssh -s $CONTAINERHOST -j DROP
iptables -A INPUT -s 61.177.0.0/16 -j DROP

iptables -L
EOF

cat > src/scripts/ssh_logger.sh <<EOF
#!/bin/ash

path="/etc/ssh"
fifoFile="\$path/ssh_fifo"

## Check if pipe exists or fail
if [[ ! -p \$fifoFile ]];then
   mkfifo \$fifoFile
   [[ ! -p \$fifoFile ]] && echo "ERROR: Failed to create FIFO file" && exit 1
fi

## Monitor the FIFO file and store the SSHD logs
while true
do
    if read line; then
       printf '[%s] %s\\n' "\$(date '+%Y-%m-%d %H:%M:%S')" "\$line" >> "/var/log/sshd_audit_$(date '+%Y-%m-%d').log"

       if printf '%s\n' "\$line" | grep -Fqe "Accepted"; then
          echo -e "To: $EMAIL\\nSubject: Alpine SSH Login\\nFrom:$EMAIL\\n\\n\$line\\n" | sendmail -t
       fi
    fi
done <"\$fifoFile"
EOF

echo "$SSHKEY\n$SSHKEYB\n" > src/config/authorized_keys

chmod go-rwx src/config/ssmtp.conf
chmod go-rwx src/scripts/ssh_logger.sh
chmod u+x src/scripts/ssh_logger.sh
chmod go-rwx src/scripts/firewall-rules.sh
chmod u+x src/scripts/firewall-rules.sh
chmod 600 src/config/authorized_keys

docker build -t stevendodd/alpine-sshd --build-arg USER=$USER --build-arg PASSWORD=$PASSWORD .
docker save --output build/image/alpine-sshd.tar stevendodd/alpine-sshd

docker tag stevendodd/alpine-sshd $DOCKERREGISTRY/stevendodd/alpine-sshd
docker push $DOCKERREGISTRY/stevendodd/alpine-sshd
