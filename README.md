# ForgeSparks LinuxGSM Docker Container

[![GitHub issues](https://img.shields.io/github/issues/ForgeSparks/docker-linuxgsm)](https://github.com/ForgeSparks/docker-linuxgsm/issues)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A custom dockerised implementation of [LinuxGSM](https://linuxgsm.com) — the command-line tool for quick, simple deployment and management of Linux dedicated game servers.

This image is a hardened, opinionated fork of the [official LinuxGSM Docker image](https://github.com/GameServerManagers/docker-linuxgsm), built on `ghcr.io/gameservermanagers/steamcmd:ubuntu-24.04` and bundled with Node.js 20 and [GameDig](https://docs.linuxgsm.com/requirements/gamedig) 5.

---

## Features

- Runs the game server as a non-root `linuxgsm` user (configurable `UID`/`GID`).
- Single persistent volume at `/data` for server files, configs, and logs.
- Graceful shutdown via `SIGTERM`/`SIGINT`/`SIGQUIT` (LinuxGSM `stop` is called before the container exits).
- Built-in Docker `HEALTHCHECK` using the LinuxGSM `monitor` module.
- Scheduled update checks via `cron` (interval configurable).
- Optional Steam `validate` on start.
- Support for LinuxGSM developer mode and custom LinuxGSM forks/branches.

## Image

```
ghcr.io/forgesparks/docker-linuxgsm:latest
```

## Quick start

Pick a `GAMESERVER` value from the [LinuxGSM supported servers list](https://linuxgsm.com/servers/) (for example `vhserver` for Valheim, `sfserver` for Satisfactory, `fctrserver` for Factorio).

```bash
docker run -d \
  --name valheim \
  -e GAMESERVER=vhserver \
  -p 2456:2456/udp \
  -p 2457:2457/udp \
  -v valheim-data:/data \
  --restart unless-stopped \
  ghcr.io/forgesparks/docker-linuxgsm:latest
```

## Docker Compose

Ready-to-use examples live under [docker-compose/](docker-compose/):

- [docker-compose/vh.yml](docker-compose/vh.yml) — Valheim (`vhserver`)
- [docker-compose/sf.yml](docker-compose/sf.yml) — Satisfactory (`sfserver`)
- [docker-compose/fctr.yml](docker-compose/fctr.yml) — Factorio (`fctrserver`)

Run one with:

```bash
docker compose -f docker-compose/vh.yml up -d
```

Minimal template:

```yaml
services:
  gameserver:
    image: ghcr.io/forgesparks/docker-linuxgsm:latest
    restart: unless-stopped
    environment:
      GAMESERVER: vhserver
    volumes:
      - data:/data
    ports:
      - 2456:2456/udp
      - 2457:2457/udp
volumes:
  data:
```

## Environment variables

| Variable            | Default              | Description                                                                                          |
| ------------------- | -------------------- | ---------------------------------------------------------------------------------------------------- |
| `GAMESERVER`        | `jc2server`          | LinuxGSM server short name (e.g. `vhserver`, `sfserver`, `fctrserver`). See the LinuxGSM docs.       |
| `UID`               | `1000`               | UID of the in-container `linuxgsm` user. Set to match the host owner of the `/data` volume.          |
| `GID`               | `1000`               | GID of the in-container `linuxgsm` user.                                                             |
| `VALIDATE_ON_START` | `false`              | If `true`, run `./<gameserver> validate` on start instead of a plain `update`.                       |
| `UPDATE_CHECK`      | `60`                 | Minutes between scheduled `update` runs via cron. Set to `0` to disable scheduled updates.           |
| `LGSM_DEV`          | `false`              | If `true`, enables LinuxGSM developer mode.                                                          |
| `LGSM_GITHUBUSER`   | `GameServerManagers` | GitHub owner used when fetching LinuxGSM modules (allows using a fork).                              |
| `LGSM_GITHUBREPO`   | `LinuxGSM`           | GitHub repo used when fetching LinuxGSM modules.                                                     |
| `LGSM_GITHUBBRANCH` | `master`             | Branch used when fetching LinuxGSM modules. Anything other than `master` triggers an `update-lgsm`.  |
| `LGSM_LOGDIR`       | `/data/log`          | Directory used for LinuxGSM logs (symlinked to `/app/log`).                                          |
| `LGSM_SERVERFILES`  | `/data/serverfiles`  | Directory used for game server files (symlinked to `/app/serverfiles`).                              |
| `LGSM_DATADIR`      | `/data/data`         | Directory used for LinuxGSM runtime data (symlinked to `/app/lgsm/data`).                            |
| `LGSM_CONFIG`       | `/data/config-lgsm`  | Directory used for LinuxGSM configs (symlinked to `/app/lgsm/config-lgsm`).                          |

## Volumes

A single volume is used to persist everything the game server needs:

| Path    | Purpose                                                                 |
| ------- | ----------------------------------------------------------------------- |
| `/data` | Server files, LinuxGSM configs, runtime data, and logs (see env vars).  |

## Ports

Ports depend entirely on the chosen `GAMESERVER`. Refer to the LinuxGSM page for your server (e.g. [Valheim](https://linuxgsm.com/servers/vhserver/), [Satisfactory](https://linuxgsm.com/servers/sfserver/), [Factorio](https://linuxgsm.com/servers/fctrserver/)) and publish them explicitly in your `docker run` / compose file.

## Healthcheck

The image ships with a `HEALTHCHECK` that runs `./<gameserver> monitor` every minute after a 2-minute start period. Container health status is visible via `docker ps` and `docker inspect`.

## Managing the server

Once running, LinuxGSM commands can be invoked inside the container as the `linuxgsm` user:

```bash
docker exec -it valheim ./vhserver details
docker exec -it valheim ./vhserver console   # attach to the tmux console (Ctrl+b then d to detach)
docker exec -it valheim ./vhserver update
docker exec -it valheim ./vhserver backup
```

Config files live under `/data/config-lgsm/<gameserver>/` inside the container (i.e. on your `data` volume).

## Building locally

```bash
docker build -t forgesparks/docker-linuxgsm:dev .
```

## License

Released under the [MIT License](LICENSE).
