#!/bin/bash
export IMG=$(docker build -q --pull --no-cache -t 'get-version' .)

export GDRIVE_VERSION=$(docker run --rm -t get-version | grep 'google-drive-ocamlfuse, version' | tr ' ' '\n' | tail -n1 | tr -d '\r')
export ALPINE_VERSION=$(docker run --rm -t --entrypoint /bin/sh get-version cat /etc/alpine-release | tail -n1 | tr -d '\r')
[ -z "$ALPINE_VERSION" ] && exit 1

export IMGTAG=$(echo "$1""a$ALPINE_VERSION-g$GDRIVE_VERSION")
export IMAGE_EXISTS=$(docker pull "$IMGTAG" 2>/dev/null >/dev/null; echo $?)

# return latest, if container is already available :)
if [ "$IMAGE_EXISTS" -eq 0 ]; then
  echo "$1""latest"
else
  echo "$IMGTAG"
fi