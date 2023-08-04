# edge-novnc
## Run Edge in docker container
```
docker build -t volansmelesmeles/edge-novnc ./
docker run -d --restart=always --name=edge-novnc -p 26080:6080 -v /data/edge-novnc:/config  volansmelesmeles/edge-novnc
```
