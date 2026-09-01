#!/bin/bash

#panel.sh - tizim disk holatini kursatsin v1

# agar ./panel.sh disk desa disk ni holatini baholab bersin uning uchun 
# argumentlarni ishlatamiz bo'sh bulsa help ga yunaltiramiz 
# -- reja --
# 1 - argument qiymati ni variable ga birlashtiramiz 
# 2 - har bir chaqiruvga tegishli javobni variable larga birlashtiramiz
# 3 - asosiy shartni beramiz 
# 4 - tekshirib kuramiz 
# 5 - upgrade qilamiz va kiro ga verify qildiramiz 
arg="$1"
#help matni 
help=" 
panel disk -- disk holati hamda hajmini kurish 
panel status -- tizim hoaltini tekshirish
panel users -- tizimdagi userslar ruyhatini olish
panel help -- panel buyrugiga doir yordam olish"

#shart qismi 'core'

if [ -z "$arg" ]; then
  echo "$help "
elif [ "$arg" = "disk" ]; then
  echo "$(df -h) $(lsblk)"
elif [ "$arg" = "status" ]; then
  echo "$(uptime)"
elif [ "$arg" = "users" ]; then
  echo "$(awk -F ':' '{print $1}' /etc/passwd)"
elif [ "$arg" = "help" ]; then
  echo "$help"
else 
  echo " iltimos to'gri argument bilan qayta urinib kuring !? "
  echo "$help"
fi
