#!/bin/bash
#rakate timerni qayta yozish eslab qolganni tekshirish uchun 

echo "| SpaceX Falcon 9 parvozga shay |"
k=1
while [ "$k" -le "3" ]; do
  read -t 15 -p " Teskari sanoqni boshlash uchun parolni kiriting " key
  if [ "$key" = "passwd" ]; then
    echo "teskari sanoq boshlanmoqda"  
  for i in {10..1}; do
      echo "$i"
      sleep 1
      done
      echo " Parvoz muvaffaqiyatli boshlandi "
      break
  else
    echo " Parol xato iltimos qayta urinib kuring !"
    k=$((k+1))
  fi
done
echo "urinishlar tugadi kirish man etildi ?X!"
