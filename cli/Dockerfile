FROM ubuntu:22.04

RUN apt-get update && \
	apt-get install -y \
		python3 \
		python3-dev \
		python3-pip \
		jq && \
	pip install \
		--upgrade pip \
		python-swiftclient \
		python-heatclient \
		python-magnumclient \
		python-manilaclient \
		python-openstackclient

CMD ["/bin/bash"]