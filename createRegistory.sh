#!/bin/sh

docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /share/Container/SharedVolumes/DockerRegistory:/var/lib/registry \
  registry