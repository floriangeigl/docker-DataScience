#!/bin/bash
cd /data/repositories/docker-DataScience
git checkout master
git reset --hard
git pull
docker rmi $(docker images -q -f dangling=true)
docker pull gcr.io/kaggle-images/python:latest
docker rmi $(docker images -q -f dangling=true)
start=$(date)
docker build -t floriangeigl/datascience:latest .
if [ $? -eq 0 ]; then
  echo "build start $start"
  echo "build done $(date)"
  echo "push image"
  docker push floriangeigl/datascience:latest
  docker tag floriangeigl/datascience:latest floriangeigl/datascience:$(date +%Y_%m)
  docker push floriangeigl/datascience:$(date +%Y_%m)
  echo "push ok"
else
  echo "build failed"
fi
cd -
sleep 120
sudo poweroff
