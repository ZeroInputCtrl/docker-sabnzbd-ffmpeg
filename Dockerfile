FROM nvidia/cuda:11.4.1-runtime-ubuntu22.04
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y ffmpeg software-properties-common
RUN add-apt-repository ppa:jcfp/nobetas
RUN apt update
RUN apt install -y sabnzbdplus nvidia-driver-470
# RUN apt upgrade -y

CMD ["sabnzbdplus"]