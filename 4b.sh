#!/bin/bash 

#rakete timer v2 
echo "| SpaceX raketasi  parvozga tayyor |"
read -t 15 -p " (parvozni tasdiqlasangiz ENTER tugmasini bosing ) : " key
if [ -z "$key" ]; then
  echo " Omadli parvoz tilayman /\/\/ (teskari sanoqni boshladim !)"
  for i in {10..1} ; do
    echo "$i"
    sleep 1
  done
  echo " raketa muvaffaqiyatli parvoz qildi !!! "  
else
echo " parvoz bekor qilindi ?x! "
fi
