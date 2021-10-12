# docker-alpine-ssh

A Containerised [SSH Jump Server](https://wiki.gentoo.org/wiki/SSH_jump_host)

## Features:
* Light weight - based on [Alpine Linux](https://hub.docker.com/_/alpine), Image size less than 15 MB
* Secure
  * [key based authentication only](https://www.cyberciti.biz/faq/how-to-disable-ssh-password-login-on-linux/)
  * limited processes running
  * OS locked down
  * no root access
  * use of private [Docker registry](https://docs.docker.com/registry/) to store image
* Auditable - logs are stored on shared volume with timestamp available
* Fully repeatable/automated install - Docker image, no manual configuration required.
* Firewall - [iptables](https://en.wikipedia.org/wiki/Iptables) available to block unwanted traffic
* [Email](https://linux.die.net/man/5/ssmtp.conf) sent on successful connect

## Prerequisites:
* QTS with Container station (or other Docker host)
  * Shared volume mount point available at: /share/logs/alpine-ssh
  * Shared volume mount point available at: /share/Container/SharedVolumes/DockerRegistory
  * [QNET](https://qnap-dev.github.io/container-station-api/qnet.html) network available (or other Docker network)
* Docker installed on Linux/MacOS workstation
  * Docker daemon configured for [insecure repository access](https://docs.docker.com/registry/insecure/) `"insecure-registries": ["DOCKERREGISTRY:5000"]`
* Personal SSH RSA/DSA key(s)
 
## Installation
##### Docker registry
SSH on to Docker host and run the docker command in createRegistory.sh (Edit script if you don't want to accept the default volume mapping and networking). The script assumes a shared volume/mount point has been created at /share/Container/SharedVolumes/DockerRegistory

A docker container will be created and exposed over a NAT port 5000
 
##### Add secrets as environment variables
Either create a file setEnvironment.sh to export the environment variables or update mkimage.sh

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

| VAR | Description |
| :--- | :--- |
| USER | The container will be installed with a single SSH user, this is the linux username that will be used. Additional users can be setup manually via the terminal features of the docker host. |
| PASSWORD | The SSH users password |
| SSHKEY | The SSH users public key that will be installed in authorized_keys |
| SSHKEYB | I have two keys, leave blank if not needed |
| EMAIL | The email address to send connection notifications to, additionally used to send email via ssmtp |
| EMAILPASSWORD | The email password for ssmtp config |
| SMTPSERVER | The SMTP server for ssmtp config |
| EMAILDOMAIN | The email domain for ssmtp config |
| DOCKERREGISTRY | The host:port of the Docker registry setup in the previous step |
| CONTAINERHOST | Used in firewall rules - see below |
| CONTAINERHOSTNETWORK | Used when creating docker-compose.yaml - see below |
| CONTAINERMACADDRESS | Used when creating docker-compose.yaml - see below |
| CONTAINERIP | Used when creating docker-compose.yaml - see below |
