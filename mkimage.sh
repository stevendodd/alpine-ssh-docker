#!/bin/sh

source ./clean.sh
mkdir -p build/image

if [ -f setEnvironment.sh ]
then
  source ./setEnvironment.sh
else
    EMAIL=myemail@outlook.com
    EMAILPASSWORD="myemail-password"
    SMTPSERVER=smtp-mail.outlook.com:587
    EMAILDOMAIN=outlook.com
    DOCKERREGISTRY=mydockerregistry:5000
    CONTAINERHOST=mycontainerhost-ip
    CONTAINERHOSTNETWORK=qnet-static-eth0-XXXX
    CONTAINERMACADDRESS=XX:XX:XX:XX:XX:XX
    CONTAINERIP=192.168.0.XX
	DEPLOYDIR=/share/Container/container-station-data/application/alpinessh
fi

cat > build/docker-compose.yml <<EOF
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
iptables -A INPUT -s 222.186.0.0/16 -j DROP
iptables -A INPUT -s 222.187.0.0/16 -j DROP
iptables -A INPUT -s 218.92.0.211 -j DROP
iptables -A INPUT -s 141.98.10.60 -j DROP

iptables -L
EOF

cat > src/scripts/docker-qnap.sh <<EOF
#!/bin/sh

PATH=/share/CACHEDEV1_DATA/.qpkg/container-station/bin:/bin
DEPLOYDIR=${DEPLOYDIR}
IMAGE=${DOCKERREGISTRY}/stevendodd/alpine-sshd 

start()
{
  if [ -d \${DEPLOYDIR} ]; then
    cd \${DEPLOYDIR}
    docker-compose up -d 
  fi  	
}

stop()
{
  if [ -d \${DEPLOYDIR} ]; then
    cd \${DEPLOYDIR}
    docker-compose down  	
  fi
}

remove()
{
	rm -fR \${DEPLOYDIR} 
	docker image rm \${IMAGE}
}

deploy()
{
	docker pull \${IMAGE}
	mkdir -p \${DEPLOYDIR}
	cp ~/docker-qnap-controller/docker-compose.yml \${DEPLOYDIR}
	start
}

if [ "\$1" = "start" ]; then
	start
	
elif [ "\$1" = "stop" ]; then
	stop

elif [ "\$1" = "deploy" ]; then
	deploy

elif [ "\$1" = "redeploy" ]; then
	stop
	remove
	deploy
	
elif [ "\$1" = "delete" ]; then
	stop
	remove
 
else
	echo "Usage docker-qnap.sh [start|stop|deploy|redeploy|delete]"
fi
EOF

chmod go-rwx src/config/ssmtp.conf
chmod go-rwx src/scripts/ssh_logger.sh
chmod go-rwx src/scripts/firewall-rules.sh
chmod u+x src/scripts/firewall-rules.sh
chmod u+x src/scripts/docker-qnap.sh


tar --exclude='sshjumpuser' -C ./users -cvf src/users.tar $(cd users ; echo *)

docker build -t stevendodd/alpine-sshd --build-arg EMAIL=$EMAIL .
docker save --output build/image/alpine-sshd.tar stevendodd/alpine-sshd

docker tag stevendodd/alpine-sshd $DOCKERREGISTRY/stevendodd/alpine-sshd
docker push $DOCKERREGISTRY/stevendodd/alpine-sshd
