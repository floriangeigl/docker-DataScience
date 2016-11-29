#!/bin/bash
mkdir -p /data/
cd /data/
#check for stored environments
if [ -f environment.yml ];
then
  conda env create -f environment.yml
fi
/usr/bin/supervisord

#start-notebook.sh
#start_jupyterlabs.sh
#start-r-server.sh
#start-ssh-server.sh
