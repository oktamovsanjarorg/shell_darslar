#!/bin/bash

# /data dagi file lar soni kupmi yoki /home buni bilishga harakat qilamiz !

#env
data=$(ls -la /data | wc -l)
home=$(ls -la /home/sanjar | wc -l)

#shart beramiz 
if [ $data -eq $home ]; then
echo " /data va /home dagai filelar soni teng ekan !!! "
elif [ $data -gt $home ]; then
echo " /data dagi filelar soni ko'proq ekan  $data "
elif [ $data -lt $home ]; then
echo " /home dagi filelar soni ko'proq ekan  $home "
else 
echo "xatolik yuz berdi , filelar soni aniqlanmadi ?!? "
fi
