FROM nvidia/cuda:12.1.0-devel-ubuntu22.04
RUN apt update && apt install -y ffmpeg software-properties-common
RUN add-apt-repository ppa:jcfp/nobetas
RUN apt update
RUN apt install -y sabnzbdplus

CMD ["sabnzbdplus"]