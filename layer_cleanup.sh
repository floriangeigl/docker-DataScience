#!/bin/bash
cd
apt-get clean -q=2 && apt-get autoremove -y -q=2
rm -rf /var/lib/apt/lists/* 
rm -rf /tmp/*
conda build purge-all -q
rm -rf ~/.cache/pip
