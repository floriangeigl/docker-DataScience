#!/bin/bash
mkdir -p /tmp/notebooks_tmp/
cd /tmp/notebooks_tmp/
exec screen -dmS ipython jupyter notebook --ip='*' --port 8888 --no-browser
