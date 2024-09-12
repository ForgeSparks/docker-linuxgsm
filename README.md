# ForgeSparks custom LinuxGSM Docker Container

A custom implementation of dockerised version of LinuxGSM https://linuxgsm.com

## Usage

### docker-compose

Below is an example `docker-compose` for csgoserver. Ports will vary depending upon server.

```docker
services:
  csgoserver:
    image: d1ceward/docker-linuxgsm:latest
    environment:
      - GAMESERVER=jc2server
      - LGSM_GITHUBUSER=GameServerManagers
      - LGSM_GITHUBREPO=LinuxGSM
      - LGSM_GITHUBBRANCH=develop
    volumes:
      - /path/to/serverfiles:/linuxgsm/serverfiles
      - /path/to/log:/linuxgsm/log
      - /path/to/config-lgsm:/linuxgsm/config-lgsm
    ports:
      - "27015:27015/tcp"
      - "27015:27015/udp"
      - "27020:27020/udp"
      - "27005:27005/udp"
    restart: unless-stopped
```
