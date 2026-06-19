#!/bin/bash

#pochta script simulator

echo "salom , sizga habar bor ! "
read -t 15 -p "habarni olish uchun kalit so'zni kiriting : " key

# verify 
if [ "$key" = "qwerty123" ]; then
  echo " barakalla kiro parolni to'gri kiritding "
elif [ -z "$key" ]; then
  echo "parol kiritilmadi ('-_-') "
else
  echo " parol xato ?! "
fi
