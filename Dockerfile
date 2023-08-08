ARG  DEBIAN_LABEL=bookworm-slim
FROM debian:${DEBIAN_LABEL}
ARG DEBIAN_LABEL

LABEL "org.debian.version"="${DEBIAN_LABEL}"

RUN \
 apt update > /dev/null 2>&1 && \
 apt upgrade -y > /dev/null 2>&1 && \
 apt install -y curl coreutils gpg software-properties-common python3-requests python3-bs4 apt-transport-https wget fonts-droid-fallback tightvncserver xfonts-base git websockify iproute2 net-tools procps xxd > /dev/null 2>&1
 
COPY rootfs /

ARG port_novnc=6080 \
port_vnc=5901 \
uname=iajd \
gname=iajd \
uid=1000 \
gid=1000 

VOLUME /config

EXPOSE $port_novnc $port_vnc

RUN \
 chmod 700 ~/*.sh && \
 bash /root/edge.install.sh | tee ~/edge.install.log && \
 rm ~/edge.install.sh && \
 git clone -qq https://github.com/novnc/noVNC.git /opt/novnc && \
 apt purge -y git > /dev/null 2>&1 && \
 apt autoremove --purge -y > /dev/null 2>&1 && \
 rm -rf /var/lib/apt/lists/* && \
 mkdir -p /config && \
 ln /opt/novnc/vnc.html /opt/novnc/index.html && \
 chmod 755 /usr/bin/edge-novnc.sh && \
 groupadd --gid ${gid} ${gname} && \ 
 useradd --home-dir /home/${uname} -g ${gname} --shell /bin/bash --create-home --uid ${uid} ${uname}

ENV \
 VNC_PASSWD=password \
 WIDTH=1600 \
 HEIGHT=900 \
 PUID=$uid \
 PGID=$gid \
 LANGUAGE=en_AU.UTF8 \
 TZ=Etc/UTC \
 PORT_NOVNC=$port_novnc \
 PORT_VNC=$port_vnc \
 __RUN_USER=$uname \
 __RUN_GROUP=$gname

CMD ["bash", "-c", "~/entrypoint.sh"]
