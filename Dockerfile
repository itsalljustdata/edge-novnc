FROM debian:bookworm-slim

RUN \
	apt update && \
	apt upgrade -y && \
    apt install --no-install-recommends -y curl gpg software-properties-common apt-transport-https wget fonts-droid-fallback tightvncserver xfonts-base git websockify iproute2 net-tools procps sudo && \
    curl --insecure https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list && \
	apt update && \
    apt install --no-install-recommends -y microsoft-edge-beta && \
	git clone https://github.com/novnc/noVNC.git /opt/novnc && \
	apt purge -y git && \
	apt autoremove --purge -y && \
	rm -rf /var/lib/apt/lists/*

VOLUME /config


ARG port_novnc=6080
ARG port_vnc=5901
ARG uname=abc
ARG gname=abc
ARG uid=1000
ARG gid=1000

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

##RUN echo "${uname} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${uname}

EXPOSE $port_novnc
EXPOSE $port_vnc

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
