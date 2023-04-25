# FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04
FROM debian:latest

RUN wget https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda-repo-debian11-12-1-local_12.1.1-530.30.02-1_amd64.deb \
  && dpkg -i cuda-repo-debian11-12-1-local_12.1.1-530.30.02-1_amd64.deb \
  && cp /var/cuda-repo-debian11-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/ \
  && add-apt-repository contrib \
  && apt-get update \
  && apt-get -y install cuda

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y ffmpeg software-properties-common
RUN add-apt-repository ppa:jcfp/nobetas
RUN apt update
# RUN apt install -y sabnzbdplus nvidia-driver-530
RUN apt install -y sabnzbdplus libnvidia-decode-530 libnvidia-encode-530

CMD ["sabnzbdplus"]