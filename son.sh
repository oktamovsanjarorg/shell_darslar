#!/bin/bash
v=$(ls -a / | wc -l)
kirit=$#
echo "$#"
if [ $# -eq $v ]; then
  echo "topshiriq bajarildi barakalla "
  break
elif [ $1 -eq 0 ]; then
  echo "DevOps task boshlandi /  da nechta file borligini tekshiring yashirinlarni ham "
  read -t 15 -p "topilgan file lar sonini kiriting : " n
    if [ $n -eq $v ]; then
      echo "topshiriq bajarildi barakalla "
    else
      echo "qaytadan urinib kuring "
    fi
else 
  echo " iltimos aniq sonlar bilan urinib kuring xato qiymat "
fi

