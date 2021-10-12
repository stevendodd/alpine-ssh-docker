# docker-alpine-ssh

Create a Containerised SSH Jump Server

Features:
* Light weight - based on Alpine Linux, Image size less than 15 MB
* Secure
  * key based authentication only
  * limited processes running
  * OS locked down
  * no root access
  * use of private Docker registry to store image
* Auditable - logs are stored on shared volume with timestamp available
* Fully repeatable/automated install - Docker image, no manual configuration required.
* Firewall - iptables available to block unwanted traffic
* Email sent on successful connect

Prerequisites:
* QTS with Container station (or other Docker host)
  * Shared volume amount available at: /share/logs/alpine-ssh
* Docker installed on Linux/MacOS workstation
  * Docker daemen configured for insecure repository access "insecure-registries": ["DOCKERREGISTRY:5000"]
* SSH RSA/DSA keys
 
