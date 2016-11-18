#!/bin/bash
mkdir -p /data/
cd /data/
exec screen -dmS rserver /usr/lib/rstudio-server/bin/rserver --server-daemonize 0 --server-working-dir /data/
