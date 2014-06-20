#!/bin/bash

# Simple bash script to forward a remote port to a local port, and try and keep it alive

#
# Note, you may want to add these to the server's /etc/ssh/sshd_config file:
#  ClientAliveInterval 10
#  ClientAliveCountMax 3
# to ensure sshd cleans up after a disconnect.

HOST="$1"
REMOTEPORT="$2"
LOCALPORT="$3"

if [ -z "$HOST" -o -z "$REMOTEPORT" ]; then
	echo Usage: $0 '<remote hostname> <remote port> [local port (22)]'
	exit 255
fi

if [ -z "$LOCALPORT" ]; then LOCALPORT=22; fi

trap "{ echo kthxbai; exit 0; }" SIGINT

while true; do
	echo -n $(date "+%H:%M:%S") "Waiting for a connection... "
	ping -o 8.8.8.8 >> /dev/null 2>&1
	echo "done. "

	echo $(date "+%H:%M:%S") Attempting to connect $HOST:$REMOTEPORT to localhost:$LOCALPORT

	ssh -N -o "ExitOnForwardFailure yes" -o "ServerAliveCountMax 3" -o "ServerAliveInterval 5" -R '*':$REMOTEPORT:127.0.0.1:$LOCALPORT $HOST
	echo $(date "+%H:%M:%S") ssh exited with $?.  Will attempt reconnect.

	sleep 1
done
