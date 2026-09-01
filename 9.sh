#!/bin/bash
#calculator uchun shell script

echo " ||   calc-cli is working...     ||"
read -t 15 -p "1 - sonni kiriting :      " bir
read -t 20 -p "amalni tanlang (+ , - , * , / ) :  " amal
read -t 15 -p "2 - sonni kiriting :  " ikki
# mitti tekshiruv 
if [ "$ikki" = "0" ]; then
  if [ "$amal" = "/" ]; then
    echo "hech qanday qiymatni 0 ga bo'lish imkonsiz"
    exit
  fi
fi
case "$amal" in
  "+")
  echo "$(($bir+$ikki))"
  ;;
  "-")
  echo "$(($bir-$ikki))"
  ;;
  "*")
  echo "$(($bir*$ikki))"
  ;;
  "/")
  echo "$(($bir/$ikki))"
  ;;
  *)
  echo "bunday amal mavjud emas "
esac
