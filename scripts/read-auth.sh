#!/bin/sh
while [ ! -f /tmp/auth.txt ]
do
  sleep 1
done
echo "VISIT THE FOLLOWING URL TO AUTHORIZE:"
cat /tmp/auth.txt