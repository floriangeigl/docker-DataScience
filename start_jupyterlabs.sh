#!/bin/bash
mkdir -p /data/
cd /data/
exec screen -dmS jupyter_labs jupyter lab --ip='*' --port 8889 --no-browser
