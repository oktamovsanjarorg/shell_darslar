#!/bin/bash 

#for sikli da teskari sanoq 
echo "| SpaceX raketasi  parvozga tayyor |"
read -t 5 -p " (parvozni tasdiqlaysizmi y/n) :  " key
if [ "$key" = "y" ]; then
  echo "parvoz tasdiqlandi omadli safar tilayman teskari sanoqni boshladim !"
  for i in 5 4 3 2 1 ; do
    echo " parvozgacha $i"
  done
  echo "succesfuly "
else
  echo "parvoz bekor qilindi ?x! "
fi
