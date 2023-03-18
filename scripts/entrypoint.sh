#!/bin/bash

export IFS=$'\n'

cat <<EOF
################################################################################

Welcome to the servercontainers/google-drive-ocamlfuse

################################################################################

# IMPORTANT!

In March 2023 - Docker informed me that they are going to remove my 
organizations `servercontainers` and `desktopcontainers` unless 
I'm upgrading to a pro plan.

I'm not going to do that. It's more of a professionally done hobby then a
professional job I'm earning money with.

In order to avoid bad actors taking over my org. names and publishing potenial
backdoored containers, I'd recommend to switch over clone my github repos and
build the containers yourself.

You'll find this container sourcecode here:

    https://github.com/ServerContainers/google-drive-ocamlfuse

The container repos will be updated regularly.

EOF

INITALIZED="/.initialized"

if [ ! -f "$INITALIZED" ]; then
  echo ">> CONTAINER: starting initialization"

  chmod a+x /container/scripts/*
  cp /container/scripts/* /bin/


  ##
  # GROUPS
  ##
  for I_CONF in $(env | grep '^GROUP_')
  do
    GROUP_NAME=$(echo "$I_CONF" | sed 's/^GROUP_//g' | sed 's/=.*//g')
    GROUP_ID=$(echo "$I_CONF" | sed 's/^[^=]*=//g')
    echo ">> CONTAINER: GROUP: adding group $GROUP_NAME with GID: $GROUP_ID"
    addgroup -g "$GROUP_ID" "$GROUP_NAME"
  done

  ##
  # USER ACCOUNTS
  ##
  for I_ACCOUNT in $(env | grep '^ACCOUNT_')
  do
    ACCOUNT_NAME=$(echo "$I_ACCOUNT" | cut -d'=' -f1 | sed 's/ACCOUNT_//g' | tr '[:upper:]' '[:lower:]')
    ACCOUNT_UID=$(echo "$I_ACCOUNT" | sed 's/^[^=]*=//g')

    echo ">> CONTAINER: ACCOUNT: adding account: $ACCOUNT_NAME with UID: $ACCOUNT_UID"
    adduser -D -H -u "$ACCOUNT_UID" -s /bin/false "$ACCOUNT_NAME"
    
    # add user to groups...
    ACCOUNT_GROUPS=$(env | grep '^GROUPS_'"$ACCOUNT_NAME" | sed 's/^[^=]*=//g')
    for GRP in $(echo "$ACCOUNT_GROUPS" | tr ',' '\n' | grep .); do
      echo ">> CONTAINER: ACCOUNT: adding account: $ACCOUNT_NAME to group: $GRP"
      addgroup "$ACCOUNT_NAME" "$GRP"
    done
  done


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
google-drive-ocamlfuse -version
exec google-drive-ocamlfuse /data -f -o uid=${PUID},gid=${PGID},noatime${MOUNT_OPTS}