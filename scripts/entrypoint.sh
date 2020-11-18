#!/bin/bash

export IFS=$'\n'

cat <<EOF
################################################################################

Welcome to the servercontainers/gdrive

################################################################################

EOF

INITALIZED="/.initialized"

if [ ! -f "$INITALIZED" ]; then
  echo ">> CONTAINER: starting initialisation"

  chmod a+x /container/scripts/*
  cp /container/scripts/* /bin/

  touch "$INITALIZED"
else
  echo ">> CONTAINER: already initialized - direct start"
fi

PUID=${PUID:-0}
PGID=${PGID:-0}

if [ -n "${MOUNT_OPTS}" ]; then
	MOUNT_OPTS=",${MOUNT_OPTS}"
fi

echo ">> CONTAINER: Run Auth Reader..."
/bin/read-auth.sh &

echo ">> CONTAINER: Run Mounting App...."
exec google-drive-ocamlfuse /data -f -o uid=${PUID},gid=${PGID},noatime${MOUNT_OPTS}