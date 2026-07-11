#!/bin/bash
export IMG=$(docker build -q --pull --no-cache -t 'get-version' .)

docker pull alpine -q >/dev/null 2>/dev/null
export GDRIVE_VERSION=$(docker run --rm -t get-version | grep 'google-drive-ocamlfuse, version' | tr ' ' '\n' | tail -n1 | tr -d '\r')
export ALPINE_VERSION=$(docker run --rm -t alpine cat /etc/alpine-release | tail -n1 | tr -d '\r')
[ -z "$ALPINE_VERSION" ] && exit 1

export IMGTAG=$(echo "$1""a$ALPINE_VERSION-g$GDRIVE_VERSION")
# FORCE_REBUILD (set by the workflow for push / manual runs) rebuilds even if
# the versioned image already exists, so code/config changes get republished.
# the nightly schedule leaves it unset and keeps deduping on the version tag.
if [ -n "$FORCE_REBUILD" ]; then
  echo "$IMGTAG"
  exit 0
fi

export IMAGE_EXISTS=$(docker pull "$IMGTAG" 2>/dev/null >/dev/null; echo $?)

# return latest, if container is already available :)
if [ "$IMAGE_EXISTS" -eq 0 ]; then
  echo "$1""latest"
else
  echo "$IMGTAG"
fi