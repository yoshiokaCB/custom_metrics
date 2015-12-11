#!/bin/sh

df -m | grep $1 | head -n 1 | tr -s ' ' | cut -d ' ' -f 4
