#!/bin/bash
mkdir -p /tmp/notebooks_tmp/
cd /tmp/notebooks_tmp/
exec screen -dmS rserver /usr/lib/rstudio-server/bin/rserver --server-daemonize 0
