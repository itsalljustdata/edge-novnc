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
else

    echo "# Getting GPG file from MS and adding repo to sources.list #"

    gpgFile="~/microsoft.gpg"
    curl --silent --insecure https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > ${gpgFile}
    install -o root -g root -m 644 ${gpgFile} /etc/apt/trusted.gpg.d/
    rm ${gpgFile}
    
    srcFileWrite="/etc/apt/sources.list.d/microsoft-edge.list"
    echo "#  Writing data to ${srcFileWrite}"
    echo "deb [arch=${thisArch}] https://packages.microsoft.com/repos/edge stable main" | tee -a ${srcFileWrite}

    echo "$0 : apt update"
    apt update

    echo "$0 : sources"
    apt-cache policy  | grep origin | sed 's/^[[:space:]]*//' | cut -d" " -f 2 | sort -u

    echo "$0 : apt install"
    apt install -y microsoft-edge-stable

    echo "$0 : after apt install"
    EDGE_EXE=`which microsoft-edge`
fi
echo "############################################################"

set -e

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
