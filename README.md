# docker-alpine-ssh

A Containerised [SSH Jump Server](https://wiki.gentoo.org/wiki/SSH_jump_host)

## Features:
* Light weight - based on [Alpine Linux](https://hub.docker.com/_/alpine)
* Secure
  * [key based authentication only](https://www.cyberciti.biz/faq/how-to-disable-ssh-password-login-on-linux/)
  * limited processes running
  * OS locked down
  * no root access
  * use of private [Docker registry](https://docs.docker.com/registry/) to store image
  * SSHD [fail2ban](https://www.fail2ban.org/wiki/index.php/MANUAL_0_8)
* Auditable - logs are stored on shared volume with timestamp available
* Fully repeatable/automated install - Docker image, no manual configuration required.
* Firewall - [iptables](https://en.wikipedia.org/wiki/Iptables) available to block unwanted traffic
* [Email](https://linux.die.net/man/5/ssmtp.conf) sent on successful connect
* Rotating logfiles via [logrotate](https://www.digitalocean.com/community/tutorials/how-to-manage-logfiles-with-logrotate-on-ubuntu-16-04)

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
| CONTAINERHOST | IP address of container host. Used in firewall rules - see below |
| CONTAINERHOSTNETWORK | The docker network to connect the container to (enables static ip address) Used when creating docker-compose.yaml - see below in my case qnet-static-eth0-XXXXX |
| CONTAINERMACADDRESS | Used when creating docker-compose.yaml - see below |
| CONTAINERIP | Used when creating docker-compose.yaml - see below |

iptables currently blocks the container host from polling the SSH port - I think my host checks open ports to dynamically create hyperlinks which generated lots of noise in the logs, it also blocks the range 61.177.0.0/16 as a few bots on that range were trying to hack me. Add additional rules via the terminal or in mkimage.sh

`[steve@dockerhost ~]$ docker network ls`
| NETWORK ID. | NAME | DRIVER | SCOPE |
| :--- | :--- | :--- | :--- |
| f40cf15886f1 | bridge | bridge | local |
| cb304d8639bb. | host | host | local |
| 615cfe4aa1ea. | none | null | local |
| b7a88c876158. | qnet-static-eth0-XXXXX | qnet | local |

##### Create image and docker-compose.yaml and upload image to private Docker registry
Run ./mkimage.sh 

##### QNAP Container station installation
* Add your new private Docker registry to Container station preferences
* Pull stevendodd/alpine-sshd image from your registry via the images screen
* Create application using docker-compose.yaml on the create screen
