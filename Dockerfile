#
# LinuxGSM Base Dockerfile
#
# https://github.com/GameServerManagers/docker-linuxgsm
#

FROM gameservermanagers/steamcmd:ubuntu-22.04

LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM=xterm
ENV LGSM_GITHUBUSER=GameServerManagers
ENV LGSM_GITHUBREPO=LinuxGSM
ENV LGSM_GITHUBBRANCH=develop
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

## Install Base LinuxGSM Requirements
RUN echo "**** Install Base LinuxGSM Requirements ****" \
  && apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository multiverse \
  && apt-get update \
  && apt-get install -y \
  cron \
  bc \
  binutils \
  bsdmainutils \
  bzip2 \
  ca-certificates \
  cpio \
  curl \
  distro-info \
  file \
  git \
  gzip \
  hostname \
  jq \
  lib32gcc-s1 \
  lib32stdc++6 \
  netcat \
  python3 \
  sudo \
  tar \
  tini \
  tmux \
  unzip \
  util-linux \
  wget \
  xz-utils \
  # Docker Extras
  iproute2 \
  iputils-ping \
  nano \
  vim \
  && apt-get -y autoremove \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*

# Install Node.js
RUN echo "**** Install Node.js ****" \
  && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
  && apt-get update \
  && apt-get install -y nodejs \
  && apt-get -y autoremove \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*

# Install GameDig https://docs.linuxgsm.com/requirements/gamedig
RUN echo "**** Install GameDig ****" \
  && npm install -g gamedig

WORKDIR /linuxgsm

## Download linuxgsm.sh
RUN echo "**** Download linuxgsm.sh ****" \
  && set -ex \
  && mkdir -p /linuxgsm/lgsm \
  && wget -O linuxgsm.sh "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/${LGSM_GITHUBBRANCH}/linuxgsm.sh" \
  && chmod +x linuxgsm.sh

# Create linuxgsm symlinks
RUN echo "**** Create Symlinks ****" \
  && ln -sn /serverfiles /linuxgsm/serverfiles \
  && ln -sn /config-lgsm /linuxgsm/lgsm/config-lgsm \
  && ln -sn /logs /linuxgsm/lgsm/logs

RUN echo "**** Get LinuxGSM Modules ****" \
  && git clone --filter=blob:none --no-checkout --sparse https://github.com/GameServerManagers/LinuxGSM.git \
  && cd LinuxGSM \
  && git sparse-checkout set --cone \
  && git sparse-checkout set lgsm/functions \
  && git checkout ${LGSM_GITHUBBRANCH} \
  && mkdir -p /linuxgsm/lgsm/functions \
  && mv lgsm/functions/* /linuxgsm/lgsm/functions \
  && chmod +x /linuxgsm/lgsm/functions/* \
  && rm -rf /linuxgsm/LinuxGSM

# Add LinuxGSM cronjobs
RUN echo "**** Create Cronjobs ****"
RUN (crontab -l 2>/dev/null; echo "*/1 * * * * /linuxgsm/*server monitor > /dev/null 2>&1") | crontab -
RUN (crontab -l 2>/dev/null; echo "*/30 * * * * /linuxgsm/*server update > /dev/null 2>&1") | crontab -

RUN rm -f /linuxgsm/entrypoint.sh
COPY entrypoint.sh /linuxgsm/entrypoint.sh
RUN date > /time.txt
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "bash","./entrypoint.sh" ]
