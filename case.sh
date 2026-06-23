#!/bin/bash

#hafta kunlari game

read -t 15 -p "qaysi kunni nomini 1-7 : " n
case "$n" in
  1)
    echo "dushanba"
    ;;
  2)
    echo "seshanba "
    ;;
  3)
    echo "chorshanba"
    ;;
  4)
    echo "payshanba"
    ;;
  5)
    echo "juma"
    ;;
  6)
    echo "shanba"
    ;;
  7)
    echo "yakshanba"
    ;;
  *)
    echo " bunday hafta kuni mavjud emas !? "
    ;;
esac
