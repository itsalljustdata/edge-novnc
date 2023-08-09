#!/bin/bash

echo "######################################################"
echo "# Launching noVNC"
echo "# script : $0"
echo "# user   : `whoami`"
echo "# home   : `realpath ~`"
echo "######################################################"

export USER=`whoami`

homeDir=`grep "^${USER}:" /etc/passwd | cut -d: -f 6`

export EDGE_CONFIG=/config/edge
PORT_NOVNC=${PORT_NOVNC:-6800}
PORT_VNC=${PORT_VNC:-5901}

if [ "$PORT_NOVNC" -eq "$PORT_VNC" ]; then
    echo "NoVNC and VNC cannot share the same port (${PORT_NOVNC})!"
    exit 1
fi
name="edge-novnc"

msedge_window_size=$[$WIDTH+1],$[$HEIGHT+1]
msedge_params="--test-type --window-size=$msedge_window_size --no-sandbox --window-position=0,0 --user-data-dir=${EDGE_CONFIG} --no-first-run --window-name=\"${name}\""
vnc_geometry=$WIDTH'x'$HEIGHT
vnc_config=${homeDir}/.vnc

[ ! -e "${EDGE_CONFIG}/First Run" ] && mkdir -p "${EDGE_CONFIG}" && touch "${EDGE_CONFIG}/First Run"
[ ! -e "$vnc_config" ] && mkdir -p $vnc_config

vncpasswd=`realpath $vnc_config/passwd`
echo $VNC_PASSWD | vncpasswd -f > $vncpasswd
chmod 700 $vncpasswd

startup=$vnc_config/xstartup

cat << EOF > "${startup}"
#!/bin/bash
while [ 1 ]; do
    ${EDGE_EXE} ${msedge_params}
done
EOF

chmod 755 $vnc_config/xstartup
chmod 755 $vnc_config
chmod 644 $vnc_config/*.log 2> /dev/null
chmod 644 $vnc_config/*.pid 2> /dev/null

running=$(ps -ef | grep -i $vncpasswd | grep -v grep | wc -l)
if [ $running -gt 0 ]; then
    echo "Kill existing vncserver"
    vncserver -kill :1 1>/dev/null 2>&1
fi

[ -e /tmp/.X11-unix ] && rm -rf /tmp/.X11-unix
[ -e /tmp/.X1-lock ] && rm -rf /tmp/.X1-lock

if ! [ -e ~/.Xauthority ]; then
    touch ~/.Xauthority
    # Generate the magic cookie with 128 bit hex encoding
    xauth add ${HOST}:0 . $(xxd -l 16 -p /dev/urandom)
fi

vncserver -name ${name} -depth 24 -geometry $vnc_geometry :1
/opt/novnc/utils/novnc_proxy --listen ${PORT_NOVNC} --vnc localhost:${PORT_VNC}