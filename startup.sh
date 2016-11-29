#!/bin/bash
mkdir -p /data/
cd /data/
#check for stored environments
if [ -f environment.yml ];
then
  conda env create -f environment.yml
fi
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    /usr/bin/supervisord
else
  /usr/bin/supervisord &>> /var/log/supervisord.log &
  exec "$@"
fi


#start-notebook.sh
#start_jupyterlabs.sh
#start-r-server.sh
#start-ssh-server.sh
