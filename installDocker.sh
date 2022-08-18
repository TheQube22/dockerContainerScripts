#!/bin/bash

# The following commands are from: https://docs.docker.com/engine/install/ubuntu/

# Uninstall old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# setup the repo
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# add docker's official key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# verify the last 8 characters of fingerprint match
sudo apt-key fingerprint 0EBFCD88

# setup the stable repo
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# install the docker engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# verify that docker engine is installed correctly
sudo docker run hello-world

