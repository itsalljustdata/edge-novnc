#/bin/bash

thisArch=`dpkg --print-architecture`

echo "############################################################"
echo "#"
echo "# User   : `whoami`"
echo "# Script : $0"
echo "# Arch   : ${thisArch}"
echo "#"


EDGE_EXE=`which microsoft-edge 2> /dev/null`
if [ $? -eq 0 ]; then
    echo "# microsoft-edge already installed : ${EDGE_EXE}"
    set -e
else
    set -e
    echo  ${thisArch} > arch.txt
    python3 /root/getdeb.py
    if [ $? -ne 0 ]; then
        exit 1
    fi
    apt install -y /tmp/msedge.deb > /dev/null 2>&1
    rm /tmp/msedge.deb
    
    EDGE_EXE=`which microsoft-edge`
fi
echo "############################################################"


EDGE_VERSION=`microsoft-edge --version | cut -d" " -f 3`

echo "### EDGE_EXE     = ${EDGE_EXE}"
echo "### EDGE_VERSION = ${EDGE_VERSION}"

function addIt () {
    fname=$1
    grep "EDGE_VERSION=" $fname || (echo "export EDGE_VERSION=${EDGE_VERSION}" | tee -a $fname)
    grep "EDGE_EXE=" $fname || (echo "export EDGE_EXE=${EDGE_EXE}" | tee -a $fname)
}

addIt /etc/environment > /dev/null

echo "$0 : Finished"
