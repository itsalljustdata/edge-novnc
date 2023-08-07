#/bin/bash



echo "############################################################"
echo "# User   : `whoami`"
echo "# Script : $0"
echo "# Shell  : `ps -p $$`"
echo "#"
EDGE_EXE=`which microsoft-edge 2> /dev/null`

if [ $? -eq 0 ]; then
    echo "microsoft-edge already installed : ${EDGE_EXE}"
else


    thisArch=$(dpkg --print-architecture)

    echo "# Getting GPG file from MS and adding repo to sources.list #"

    srcList='/etc/apt/sources.list'

    if [ -e $srcList ]; then
        srcFileWrite=${srcList}
    else
        srcFileWrite="${srcList}.d/microsoft-edge.list"
    fi

    echo ${srcFileWrite}
    echo "############################################################"

    gpgFile='/usr/share/keyrings/microsoft.gpg'

    curl --silent --insecure https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o ${gpgFile}

    echo "deb [arch=${thisArch} signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | tee -a ${srcFileWrite}

    apt update > /dev/null 2>&1

    apt install -y microsoft-edge-stable > /dev/null 2>&1

    EDGE_EXE=`which microsoft-edge`
fi

EDGE_VERSION=`microsoft-edge --version | cut -d" " -f 3`

echo "### EDGE_EXE     = ${EDGE_EXE}"
echo "### EDGE_VERSION = ${EDGE_VERSION}"

function addIt () {
    fname=$1
    grep "EDGE_VERSION=" $fname || (echo "export EDGE_VERSION=${EDGE_VERSION}" | tee -a $fname)
    grep "EDGE_EXE=" $fname || (echo "export EDGE_EXE=${EDGE_EXE}" | tee -a $fname)
}

addIt /etc/environment

echo "$0 : Finished"
