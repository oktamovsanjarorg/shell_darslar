#!/bin/bash
# while v2 

n="1"

while [ $n -le "10000000" ]; do
  echo "$n"
  n=$((n+1))
done
