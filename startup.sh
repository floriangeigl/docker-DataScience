#!/bin/bash
mkdir -p /data/
cd /data/
#check for stored environments
if [ -f environment.yml ];
then
  conda env create -f environment.yml
fi
echo "args: $@"
if [[ "$@" -eq "" ]]
  then
    echo "No arguments supplied"
    /usr/bin/supervisord
else
  /usr/bin/supervisord >> /var/log/supervisord.log 2>&1 &
  exec "$@"
fi


#start-notebook.sh
#start_jupyterlabs.sh
#start-r-server.sh
#start-ssh-server.sh
