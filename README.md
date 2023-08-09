# edge-novnc
## Run Edge in docker container

Runs ms-edge in a NoVNC docker container (debian/bookworm-slim based)

### Environment Vars

| Variable | Description | Default |
| -------- | ----------- | ------- |
|	`VNC_PASSWD` | Password (max 8 chars) | `password` |
| `WIDTH` | Window Width | `1600` |
| `HEIGHT` | Window Height | `900` |
| `PUID` | User Id to run as inside container | `1000` |
| `PGID` | Group Id to run as inside container | `1000` |
| `LANGUAGE` | Language | `en_AU.UTF8` |
| `PORT_NOVNC` | Internal NoVNC Port | `6080` |
| `PORT_VNC` | Internal VNC Port | `5901` |
| `TZ` | Container TZ | `Etc/UTC` |

### Launching Container

#### docker run
```
docker run -d \
 --restart=unless-stopped \
 --name=edge-novnc \
 -p 26080:6080 \
 -v /data/edge-novnc:/config \
 itsalljustdata/edge-novnc
```


#### docker compose
See [docker-compose.yml](docker-compose.yml)
