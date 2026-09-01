#!/bin/bash
#case lar oqali panel loyihasini 2 - versia sini yaratamiz !

#vaqtni tezlashtirish uchun argumentlarni panel.sh ni uzidan copy qildik !

arg="$1"
#help matni 
help=" 
panel2 disk -- disk holati hamda hajmini kurish 
panel2 status -- tizim hoaltini tekshirish
panel2 users -- tizimdagi userslar ruyhatini olish
panel2 help -- panel buyrugiga doir yordam olish"
#disk ni holati va xotira
disk=$(echo "$(df -h) $(lsblk)")
#users uchun javobni tayyorlaymiz !
users=$(awk -F ":" '{print $1}' /etc/passwd)
# status uchun chiqish 
status=$(echo "$(uptime)  $(date)")

case "$arg" in
  "disk")
  echo "$disk"
  ;;
  "status")
  echo "$status"
  ;;
  "users")
  echo "$users "
  ;;
  "help")
  echo "$help"
  ;;
  *)
  echo "I don't know this argument, please try again ! $help"
  exit 1
  ;;
esac
