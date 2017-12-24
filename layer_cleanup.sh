#!/bin/bash
cd
apt-get clean && apt-get autoremove -y 
rm -rf /var/lib/apt/lists/* 
rm -rf /tmp/*
conda clean -i -l -t -s -y
rm -rf ~/.cache/pip
