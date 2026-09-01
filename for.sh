#!/bin/bash

for i in {1..5}; do
  [[ $i -eq 3 ]] && continue
  echo $i
done
