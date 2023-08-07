FROM debian:bookworm-slim

RUN \
 apt update > /dev/null 2>&1 && \
 apt upgrade -y > /dev/null 2>&1 && \
 apt install --no-install-recommends -y curl gpg software-properties-common apt-transport-https wget fonts-droid-fallback tightvncserver xfonts-base git websockify iproute2 net-tools procps && \
 curl --insecure https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg

RUN \
 echo "deb [arch=`dpkg --print-architecture` signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list && \
 apt update > /dev/null 2>&1 && \
 apt install --no-install-recommends -y microsoft-edge-beta > /dev/null 2>&1
 
RUN \
 git clone -qq https://github.com/novnc/noVNC.git /opt/novnc && \
 apt purge -y git > /dev/null 2>&1 && \
 apt autoremove --purge -y > /dev/null 2>&1 && \
 rm -rf /var/lib/apt/lists/*

VOLUME /config

ARG port_novnc=6080 \
port_vnc=5901 \
uname=abc \
gname=abc \
uid=1000 \
gid=1000 

# Configuration
COPY edge-novnc.sh /usr/bin/edge-novnc.sh
COPY entrypoint.sh /entrypoint.sh
RUN \
 mkdir -p /config && \
 ln /opt/novnc/vnc.html /opt/novnc/index.html && \
 chmod 755 /usr/bin/edge-novnc.sh && \
 chmod 700 /entrypoint.sh && \
 groupadd -g ${gid} ${gname} && \ 
 useradd --home-dir /home/${uname} -g ${gname} -m -u ${uid} ${uname}

EXPOSE $port_novnc $port_vnc

ENV \
 VNC_PASSWD=password \
 WIDTH=1600 \
 HEIGHT=900 \
 PUID=$uid \
 PGID=$gid \
 LANGUAGE=en_AU.UTF8 \
 PORT_NOVNC=$port_novnc \
 PORT_VNC=$port_vnc \
 TZ=Etc/UTC

CMD ["bash", "-c", "/entrypoint.sh"]
