FROM ubuntu:bionic
RUN apt-get clean && apt-get update && apt-get install -y python3.6
RUN apt-get -y install --reinstall python3-apt
RUN ln -sf /usr/bin/python3.6 /usr/bin/python
