FROM ubuntu:24.04

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		python3 \
		python3-dev \
		python3-pip \
		jq \
		python3-swiftclient \
		python3-heatclient \
		python3-magnumclient \
		python3-manilaclient \
		python3-openstackclient

CMD ["/bin/bash"]