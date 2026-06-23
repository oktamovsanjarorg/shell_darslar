#!/bin/bash
#calculator uchun shell script

echo " || calc-cli is working... ||"
read -t 15 -p "1 - sonni kiriting :  " bir
read -t 20 -p "amalni tanlang (+ , - , * , / ) :  " amal
read -t 15 -p "2 - sonni kiriting :  " ikki

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
