#/bin/bash

thisArch=$(dpkg --print-architecture)
echo "############################################################"
echo "# Getting GPG file from MS and adding repo to sources.list #"
echo "# Architecture = $thisArch"
echo "############################################################"

gpgFile='/usr/share/keyrings/microsoft.gpg'

curl --silent --insecure https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o ${gpgFile}

srcList='/etc/apt/sources.list'

if [ -e $srcList ]; then
    srcFileWrite=${srcList}
else
    srcFileWrite="${srcList}.d/microsoft-edge.list"
fi

echo "~ sources.list ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ${srcFileWrite}
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

echo "deb [arch=${thisArch} signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | tee -a ${srcFileWrite}

apt update > /dev/null 2>&1

apt install --no-install-recommends -y microsoft-edge-beta > /dev/null 2>&1
