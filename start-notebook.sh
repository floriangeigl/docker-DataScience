#!/bin/bash
mkdir -p /data/
cd /data/
exec screen -dmS jupyter_notebook jupyter notebook --ip='*' --port 8888 --no-browser
