#!/bin/bash
son=0
while read qator; do
  echo "o'qildi $qator"
  son=$(($son+1))
done < qator.txt
echo " jami ismlar : $son "
