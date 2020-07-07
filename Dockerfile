FROM linuxserver/sabnzbd:unstable

RUN apt-get update && \
    apt-get install -y \
	    ffmpeg && \
echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
	    /tmp/* \
	    /var/lib/apt/lists/* \
	    /var/tmp/*
