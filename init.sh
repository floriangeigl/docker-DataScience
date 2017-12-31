#!/bin/bash
mkdir -p /data/
cd /data/
#check for stored environments
if [ -f environment.yml ]; then
  conda env create -f environment.yml
fi

echo "starting notebooks..."
if [[ "$@" != "" ]]; then
  /usr/bin/supervisord >> /var/log/supervisord.log 2>&1 &
  exec "$@"  
else
  echo "No arguments supplied"
  /usr/bin/supervisord
fi
