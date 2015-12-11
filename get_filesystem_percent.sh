#!/bin/sh

df | grep $1 | head -n 1 | tr -s ' ' | cut -d ' ' -f 5 | cut -d '%' -f 1
