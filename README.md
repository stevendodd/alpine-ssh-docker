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
  * [QNET](https://qnap-dev.github.io/container-station-api/qnet.html) network available (or other Docker network)
* Docker installed on Linux/MacOS workstation
  * Docker daemon configured for [insecure repository access](https://docs.docker.com/registry/insecure/) `"insecure-registries": ["DOCKERREGISTRY:5000"]`
* Personal SSH RSA/DSA key(s)
 
