#!/bin/bash

if [[ -z "$NGROK_TOKEN" ]]; then
  echo "Please set 'NGROK_TOKEN'"
  exit 2
fi

if [[ -z "$USER_PASS" ]]; then
  echo "Please set 'USER_PASS' for user: $USER"
  exit 3
fi

echo -e "$USER_PASS\n$SSH_PASSWORD" | sudo passwd "$USER"

rm -f .ngrok.log
./ngrok authtoken "$NGROK_TOKEN"
./ngrok tcp 22 --log ".ngrok.log" &

sleep 10

HAS_ERRORS=$(grep "command failed" < .ngrok.log)

if [[ -z "$HAS_ERRORS" ]]; then
  echo ""
  echo "To connect: $($(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")"' change to 'echo "To connect: $(grep -o -E "http://(.+)&quot; < .ngrok.log | sed "s/http:\/\//ssh $USER@/" | sed "s/:/ -p /")"'
else
  echo "$HAS_ERRORS"
  exit 4
fi
