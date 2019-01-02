#!/bin/bash
docker system prune -a -f
docker rmi $(docker images -a -q)
docker system prune -a -f
