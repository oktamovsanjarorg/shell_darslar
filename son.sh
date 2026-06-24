#!/bin/bash
v=$(ls -a / | wc -l)
key=$1
if [ -z $key ]; then
  echo "/  da nechta file borligini tekshiring yashirinlarni ham "
  read -t 15 -p "topilgan file lar sonini kiriting : " n
    if [ $n -eq $v ]; then
      echo "topshiriq bajarildi barakalla "
    else
      echo "qaytadan urinib kuring "
    fi
elif [ $key -eq $v ]; then
  echo "topshiriq bajarildi barakalla "
else 
  echo " iltimos aniq sonlar bilan urinib kuring xato qiymat "
fi
