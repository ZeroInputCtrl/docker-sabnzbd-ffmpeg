# FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04
FROM debian:11

# RUN mkdir '/root/sabnzbd'

# RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y software-properties-common \
  wget curl jq python3-pip build-essential yasm \
  cmake libtool libc6 libc6-dev unzip libnuma1 libnuma-dev
RUN add-apt-repository contrib
RUN add-apt-repository non-free
RUN apt update

# RUN apt install -y sabnzbdplus nvidia-driver-530
RUN apt install -y libjs-bootstrap libjs-jquery \
  libjs-jquery-ui libjs-moment lsb-base par2 \
  python3-chardet python3-cheetah python3-cherrypy3 \
  python3-configobj python3-cryptography python3-feedparser \
  python3-portend python3-sabyenc python3-six unrar rar

WORKDIR /root

RUN curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest > release.json
RUN jq -r '.assets[] | select( .name | contains(".tar.gz") ) | .' release.json > release
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
RUN apt remove -y gcc
RUN apt install -y git libgcc-9-dev
RUN apt install -y libavcodec-extra58 libavdevice58 libavfilter-extra7 \
  libavformat58 libavresample4 libavutil56 libc6 libpostproc55 \
  libsdl2-2.0-0 libswresample3 libswscale5
RUN apt install -y autoconf \
  automake \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libmp3lame-dev \
  libsdl2-dev \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  meson \
  ninja-build \
  pkg-config \
  texinfo \
  zlib1g-dev
ENV PATH=$PATH:/usr/local/cuda/bin 
RUN mkdir nvidia
WORKDIR /root/nvidia
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git \
  && (cd nv-codec-headers && sudo make install)
RUN git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg/
RUN ( \
  cd ffmpeg/ \
  && ./configure --prefix=/usr/local/ffmpeg-nvidia \
        --extra-cflags=-I/usr/local/cuda/include \
        --extra-ldflags=-L/usr/local/cuda/lib64 \
        --toolchain=hardened \
        --enable-gpl \
        --disable-stripping \
        --disable-filter=resample \
        --enable-cuvid \
        --enable-gnutls \
        --enable-ladspa \
        --enable-libaom \
        --enable-libass \
        --enable-libbluray \
        --enable-libbs2b \
        --enable-libcaca \
        --enable-libcdio \
        --enable-libcodec2 \
        --enable-libfdk-aac \
        --enable-libflite \
        --enable-libfontconfig \
        --enable-libfreetype \
        --enable-libfribidi \
        --enable-libgme \
        --enable-libgsm \
        --enable-libjack \
        --enable-libmp3lame \
        --enable-libmysofa \
        --enable-libnpp \
        --enable-libopenjpeg \
        --enable-libopenmpt \
        --enable-libopus \
        --enable-libpulse \
        --enable-librsvg \
        --enable-librubberband \
        --enable-libshine \
        --enable-libsnappy \
        --enable-libsoxr \
        --enable-libspeex \
        --enable-libssh \
        --enable-libtheora \
        --enable-libtwolame \
        --enable-libvorbis \
        --enable-libvidstab \
        --enable-libvpx \
        --enable-libwebp \
        --enable-libx265 \
        --enable-libxml2 \
        --enable-libxvid \
        --enable-libzmq \
        --enable-libzvbi \
        --enable-lv2 \
        --enable-nvenc \
        --enable-nonfree \
        --enable-omx \
        --enable-openal \
        --enable-opencl \
        --enable-opengl \
        --enable-sdl2 \
        --enable-cuda-nvcc \
  && make -j $(nproc) \
  && ls -l ffmpeg \
  && ./ffmpeg \
  && make install \
  && ls -l /usr/local/bin/ffmpeg \
  && type -a ffmpeg \
  )

RUN echo "$PATH"
ENV PATH=$PATH:/usr/local/bin
RUN echo "$PATH"

CMD ["/root/sabnzbd/SABnzbd.py"]