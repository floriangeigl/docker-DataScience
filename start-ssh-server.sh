#!/bin/bash
exec screen -dmS ssh-server /usr/sbin/sshd -D
