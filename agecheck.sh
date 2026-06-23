#!/bin/bash

#yosh tekshir game 18 yosh uchun 

#funksiya yozib olamiz 
age() {
  if [ "$1" -ge "18" ] ; then
    return 0
  else
    return 1
  fi
}
read -t 15 -p "yoshingiz nechchida ? " n
age "$n"
if [ "$?" -eq 0 ]; then
  echo "kirish tasdiqlandi "
else
  echo "accses denied"
fi
