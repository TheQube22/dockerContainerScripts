=============================
DOCKER
============================
- Untar the sln_docker.tar.gz archive
	tar -zxvf sln_docker.tar.gz

- Go inside the directory
- To build the image, run the docker build command
  NOTE: DO NOT IGNORE THE PERIOD
	sudo docker build -t sln_image:v0.1 .

-------------------------
Dockerfile
-------------------------
See the Dockerfle in the directory to see how to install
new packages and see how to copy/add items onto the image

In the near future, I will create a Docker-compose file
to show how to quickly deploy many docker container specific
settings, and keep the keep the files that will change 
a lot outside of the image so you don't have to keep 
generating them. 


