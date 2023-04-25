# FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04
FROM debian:11

# RUN mkdir '/root/sabnzbd'

# RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y ffmpeg software-properties-common wget curl jq python3-pip
RUN add-apt-repository contrib
RUN add-apt-repository non-free
RUN apt update

# RUN apt install -y sabnzbdplus nvidia-driver-530
RUN apt install -y sabnzbdplus

WORKDIR /root

RUN echo $(curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest) | jq -r '.assets[] | select( .name | contains(".tar.gz") ) | .' > release
RUN jq -r '.name' release > filename
RUN jq -r '.browser_download_url' release > download_url
RUN wget "$(cat download_url)"
RUN tar xvzf "$(cat filename)" && rm "$(cat filename)"
RUN folder="$(ls | grep SAB)" \
  && mv "${folder}" sabnzbd
RUN (cd sabnzbd; pip3 install -r requirements.txt)

RUN wget https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda-repo-debian11-12-1-local_12.1.1-530.30.02-1_amd64.deb \
  && dpkg -i cuda-repo-debian11-12-1-local_12.1.1-530.30.02-1_amd64.deb \
  && cp /var/cuda-repo-debian11-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/ \
  && apt update \
  && apt -y install cuda
  # && apt update \
  # && apt install -y libnvidia-decode-530 libnvidia-encode-530


CMD ["/root/sabnzbd/SABnzbd.py"]