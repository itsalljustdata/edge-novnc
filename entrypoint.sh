#!/bin/bash

set -e

runUser=abc
runGroup=abc

PUID=${PUID:-1000}
PGID=${PGID:-1000}

uid=`id -u ${runUser}`
gid=`id -g ${runGroup}`

chownNeeded=0

# Set GroupId
if [ ${gid} -ne ${PGID} ]; then
    tmp=`grep ":${PGID}:" /etc/group | cut -d: -f 1`
    if [ "$tmp" == "" ]; then
        echo "${runGroup} : Changing GID from ${gid} to ${PGID}"
        groupmod --gid $PGID ${runGroup}
    else
        runGroup=$tmp
        echo "GID ${PGID} already exists: running as group \"${runGroup}\""
        chownNeeded=1
        usermod -aG $PGID ${runUser}
    fi
fi

# Set UserId
if [ ${uid} -ne ${PUID} ]; then
    tmp=`id -nu $PUID 2> /dev/null`
    if [ "${tmp}" == "" ]; then
        echo "${runUser} : Changing UID from ${uid} to ${PUID}"
        usermod --uid ${PUID} ${runUser}
    else
        runUser=$tmp
        echo "UID ${PUID} already exists: running as \"${runUser}\""

        status=`passwd -S ${runUser} | cut -d' ' -f 2 2> /dev/null`
        if [ "${status:0:1}" == "L" ]; then
            echo "Account \"${runUser}\" is locked. Cannot proceed. Modify PUID environment variable"
            exit 1
        fi
        
        chownNeeded=1
        passwdEntry=`grep "^${runUser}:" /etc/passwd`
        mkdir -p `echo $passwdEntry | cut -d: -f 6` 2> /dev/null
        usermod -aG $PGID ${runUser}
    fi
fi

if [ $chownNeeded -eq 1 ]; then
    chown -R ${runUser}:${runGroup} /config
fi

echo "Spawning edge-novnc as user \"${runUser}\", group \"${runGroup}\""
su --group ${runGroup} --command 'bash /usr/bin/edge-novnc.sh' ${runUser}