#/bin/bash
source activate R
/usr/bin/xvfb-run -a /usr/lib/rstudio-server/bin/rserver --server-daemonize 0 --server-working-dir /data --rsession-which-r /opt/conda/envs/R/bin/R --server-app-armor-enabled=0
