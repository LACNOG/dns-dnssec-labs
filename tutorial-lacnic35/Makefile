# Build container 
#
id = 35
imgname = lacnic-tutorial-base:$(id)
contname = lacnic$(id)-tutorial

help:
	-echo "Use build, run or shell"

build:
	docker build -t $(imgname) .

run:
	-docker rm $(contname);
	docker run -d --name $(contname) -v $$(pwd):/ext $(imgname) sleep 600 

stop:
	docker stop $(contname)

shell:
	docker exec -ti $(contname) /bin/bash
