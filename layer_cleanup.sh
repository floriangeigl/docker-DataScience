#!/bin/bash
cd
apt-get clean -q=2 && apt-get autoremove -y -q=2
rm -rf /var/lib/apt/lists/* 
rm -rf /tmp/*
conda clean -i -l -t -s -y -q
rm -rf ~/.cache/pip
