build:
	docker build -t ansible_ubuntu:bionic .

run:
	-docker rm happy-everafter;
	docker run -d --name happy-everafter ansible_ubuntu:bionic sleep 600 

provision: 
	./mk

shell:
	docker exec -ti happy-everafter /bin/bash
