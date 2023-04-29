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

RUN wget https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda-repo-debian11-12-1-local_12.1.1-530.30.02-1_amd64.deb \
  && dpkg -i cuda-repo-debian11-12-1-local_12.1.1-530.30.02-1_amd64.deb \
  && cp /var/cuda-repo-debian11-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/ \
  && apt update \
  && apt -y install cuda \
  && rm -rf /var/cuda-repo-debian11-12-1-local /root/cuda-repo-debian11-12-1-local_12.1.1-530.30.02-1_amd64.deb \
  && apt -y remove nvidia-*
  # && apt update \
  # && apt install -y libnvidia-decode-530 libnvidia-encode-530
RUN apt install -y libavcodec-extra58 libavdevice58 libavfilter-extra7 \
  libavformat58 libavresample4 libavutil56 libc6 libpostproc55 \
  libsdl2-2.0-0 libswresample3 libswscale5 autoconf \
  automake cmake git-core libass-dev libfreetype6-dev \
  libgnutls28-dev libmp3lame-dev libsdl2-dev libva-dev \
  libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
  libxcb-xfixes0-dev meson ninja-build pkg-config texinfo \
  zlib1g-dev libx264-dev nasm libx265-dev libnuma-dev \
  libvpx-dev libfdk-aac-dev libopus-dev libdav1d-dev gcc \
  g++ gnutls-bin libunistring-dev libaom-dev ladspa-sdk \
  liblilv-dev libbluray-dev liblzma-dev libbs2b-dev libcaca-dev \
  libcodec2-dev flite1-dev libgme-dev libgsm1-dev \
  libmysofa-dev libopenjp2-7-dev libopenmpt-dev librsvg2-dev \
  librubberband-dev libshine-dev libsnappy-dev libsoxr-dev \
  libssh-dev libspeex-dev libtheora-dev libtwolame-dev \
  libvidstab-dev libwebp-dev libxvidcore-dev libzvbi-dev \
  libopenal-dev libjack-dev libcdio-paranoia-dev
ENV PATH=$PATH:/usr/local/cuda/bin 
RUN mkdir nvidia
WORKDIR /root/nvidia
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git \
  && (cd nv-codec-headers && sudo make install)
# RUN git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg/

WORKDIR /root
RUN mkdir -p ffmpeg_sources bin
ENV PATH=$PATH:/root/bin
WORKDIR /root/ffmpeg_sources
# RUN git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && \
#   mkdir -p SVT-AV1/build && \
#   cd SVT-AV1/build && \
#   PATH="/root/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/root" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF .. && \
#   PATH="/root/bin:$PATH" make && \
#   make install \
#   cp 
RUN wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
  tar xjvf ffmpeg-snapshot.tar.bz2 \
  && ( \
  cd ffmpeg/ \
  && ./configure \
        --extra-cflags=-I/usr/local/cuda/include \
        --extra-ldflags=-L/usr/local/cuda/lib64 \
        --prefix="/root/ffmpeg_build" \
        --pkg-config-flags="--static" \
        --extra-cflags="-I/root/ffmpeg_build/include" \
        --extra-ldflags="-L/root/ffmpeg_build/lib" \
        --extra-libs="-lpthread -lm" \
        --ld="g++" \
        --bindir="/root/bin" \
        --toolchain=hardened \
        --enable-gpl \
        --enable-gnutls \
        --enable-libaom \
        --enable-libass \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libdav1d \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libx264 \
        --enable-libx265 \
        --enable-nonfree \
        --enable-cuvid \
        --enable-ladspa \
        --enable-libbluray \
        --enable-libbs2b \
        --enable-libcaca \
        --enable-libcdio \
        --enable-libcodec2 \
        --enable-libflite \
        --enable-libfontconfig \
        --enable-libfribidi \
        --enable-libgme \
        --enable-libgsm \
        --enable-libjack \
        --enable-libmysofa \
        --enable-libnpp \
        --enable-libopenjpeg \
        --enable-libopenmpt \
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
        --enable-libvidstab \
        --enable-libwebp \
        --enable-libxml2 \
        --enable-libxvid \
        --enable-libzvbi \
        --enable-lv2 \
        --enable-nvenc \
        --enable-openal \
        --enable-opencl \
        --enable-opengl \
        --enable-sdl2 \
        --enable-cuda-nvcc \
        # --enable-libsvtav1 \
        # --enable-omx \
        # --enable-libzmq \
        # --disable-stripping \
        # --disable-filter=resample \
  && make -j $(nproc) \
  && make install \
  && rm -rf /root/ffmpeg_sources \
  )
  RUN apt clean autoclean
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

CMD ["/root/sabnzbd/SABnzbd.py"]