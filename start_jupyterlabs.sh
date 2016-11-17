#!/bin/bash
mkdir -p /data/
cd /data/
exec screen -dmS ipython jupyter lab --ip='*' --port 8889 --no-browser
