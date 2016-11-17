#!/bin/bash
mkdir -p /data/
cd /data/
exec screen -dmS ipython jupyter notebook --ip='*' --port 8888 --no-browser
