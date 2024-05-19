# FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04
FROM linuxserver/ffmpeg:latest

RUN apt update; apt install -y sabnzbdplus && \
  echo "**** clean up ****" && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/*
ENTRYPOINT '/bin/bash'
CMD ["sabnzbdplus", "--config-file /config", "--server 0.0.0.0"]
