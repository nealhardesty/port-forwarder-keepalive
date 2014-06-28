#!/bin/bash

# Simple bash script to forward a remote port to a local port, and try and keep it alive

#
# Note, you may want to add these to the server's /etc/ssh/sshd_config file:
#  ClientAliveInterval 10
#  ClientAliveCountMax 3
# to ensure sshd cleans up after a disconnect.

REMOTEHOST="$1"
REMOTEPORT="$2"
LOCALHOST="$3"
LOCALPORT="$4"

if [ -z "$REMOTEHOST" -o -z "$REMOTEPORT" ]; then
	echo Usage: $0 '<remote hostname> <remote port> [local host (localhost)] [local port (22)]'
	exit 255
fi

if [ -z "$LOCALHOST" ]; then LOCALHOST=127.0.0.1; fi
if [ -z "$LOCALPORT" ]; then LOCALPORT=22; fi

trap "{ echo kthxbai; exit 0; }" SIGINT

while true; do
	echo -n $(date "+%H:%M:%S") "Waiting for a connection... "
	ping -o 8.8.8.8 >> /dev/null 2>&1
	echo "done. "

	echo $(date "+%H:%M:%S") Attempting to connect $REMOTEHOST:$REMOTEPORT to $LOCALHOST:$LOCALPORT

	ssh -N -o "ExitOnForwardFailure yes" -o "ServerAliveCountMax 3" -o "ServerAliveInterval 5" -R '*':$REMOTEPORT:$LOCALHOST:$LOCALPORT $REMOTEHOST
	echo $(date "+%H:%M:%S") ssh exited with $?.  Will attempt reconnect.

	sleep 1
done
