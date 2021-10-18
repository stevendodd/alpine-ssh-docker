# docker-alpine-ssh

A Containerised [SSH Jump Server](https://wiki.gentoo.org/wiki/SSH_jump_host)

## Features:
* Light weight - based on [Alpine Linux](https://hub.docker.com/_/alpine)
* Secure
  * Multi user [key based authentication only](https://www.cyberciti.biz/faq/how-to-disable-ssh-password-login-on-linux/)
  * limited processes running
  * OS locked down / fschecking
  * no root access
  * use of private [Docker registry](https://docs.docker.com/registry/) to store image
  * SSHD [fail2ban](https://www.fail2ban.org/wiki/index.php/MANUAL_0_8)
* Auditable - logs are stored on shared volume with timestamp available
* Fully repeatable/automated install - Docker image, no manual configuration required.
* Firewall - [iptables](https://en.wikipedia.org/wiki/Iptables) available to block unwanted traffic
* [Email](https://linux.die.net/man/5/ssmtp.conf) sent on successful connect
* Rotating logfiles via [logrotate](https://www.digitalocean.com/community/tutorials/how-to-manage-logfiles-with-logrotate-on-ubuntu-16-04)
* Optional deployment scripts, one command build and deploy 

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

##### Add users and authorized_keys
As per the 'sshjumpuser' example; for each ssh user you would like to grant access, create a folder under the ./users directory (the folder name will become the username) and add their authorized_keys public keys.
 
##### Add secrets as environment variables
Either create a file setEnvironment.sh to export the environment variables or update mkimage.sh

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

| VAR | Description |
| :--- | :--- |
| EMAIL | The email address to send connection notifications to, additionally used to send email via ssmtp |
| EMAILPASSWORD | The email password for ssmtp config |
| SMTPSERVER | The SMTP server for ssmtp config |
| EMAILDOMAIN | The email domain for ssmtp config |
| DOCKERREGISTRY | The host:port of the Docker registry setup in the previous step |
| CONTAINERHOST | IP address of container host. Used in firewall rules - see below |
| CONTAINERHOSTNETWORK | The docker network to connect the container to (enables static ip address) Used when creating docker-compose.yaml - see below in my case qnet-static-eth0-XXXXX |
| CONTAINERMACADDRESS | Used when creating docker-compose.yaml - see below |
| CONTAINERIP | Used when creating docker-compose.yaml - see below |
| DEPLOYDIR | Optional - Image application directory for deployment |

iptables currently blocks the container host from polling the SSH port - I think my host checks open ports to dynamically create hyperlinks which generated lots of noise in the logs, it also blocks the range 61.177.0.0/16 as a few bots on that range were trying to hack me. Add additional rules via the terminal or in mkimage.sh

`[steve@dockerhost ~]$ docker network ls`
| NETWORK ID. | NAME | DRIVER | SCOPE |
| :--- | :--- | :--- | :--- |
| f40cf15886f1 | bridge | bridge | local |
| cb304d8639bb. | host | host | local |
| 615cfe4aa1ea. | none | null | local |
| b7a88c876158. | qnet-static-eth0-XXXXX | qnet | local |

##### Optional one command build and deploy
Either add to setEnvironment.sh to export the environment variables or update controlServer.sh

	DOCKERUSER=docker
	CONTAINERHOSTHOMEDIR=/home

| VAR | Description |
| :--- | :--- |
| DOCKERUSER | The docker user on your docker host - needs ssh access from your build machine  |
| CONTAINERHOSTHOMEDIR | The home directory on the docker host |

Run ./controlServer.sh deploy 
./controlServer.sh delete

##### Otherwise Create image and docker-compose.yml and upload image to private Docker registry
Run ./mkimage.sh 

##### QNAP Container station installation
* Add your new private Docker registry to Container station preferences
* Pull stevendodd/alpine-sshd image from your registry via the images screen
* Create application using build/docker-compose.yml on the create screen

All thats left to do is forward external requests on port 22 to the new jump server
