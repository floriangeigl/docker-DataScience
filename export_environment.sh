#!/bin/bash
cd /data/
if [ -f environment.yml ];
then
  read -r -p "Environment file already exisits. Overwrite? [y/N] " response
  response=${response,,}    # tolower
  if [[ $response =~ ^(yes|y)$ ]]
  then
    conda env export > environment.yml
   fi
else
  conda env export > environment.yml
fi

