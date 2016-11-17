#!/bin/bash
mkdir -p /data/
cd /data/
#check for stored environments
if [ -f environment.yml ];
then
  conda env create -f environment.yml
fi

exec screen -dmS ipython jupyter notebook --ip='*' --port 8888 --no-browser
