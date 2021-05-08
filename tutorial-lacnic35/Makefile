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
	docker run -d --name $(contname) $(imgname) sleep 600 

shell:
	docker exec -ti $(contname) /bin/bash
