#!/bin/bash

#  1. O'zgaruvchi e'lon qiling: FILE_PATH="/var/log/nginx/access.log"
# 2. Undan faqat fayl nomini ajratib oling (access.log) va ekranga chiqaring (##
# 3. Undan faqat fayl kengaytmasini ajratib oling (log) va ekranga chiqaring (% yoki ## yordamida).
#  4. Docker image nomi: IMAGE="nginx:latest"
#  5. latest so'zini 1.25.3 ga almashtirib, ekranga chiqaring (/ yordamida).

FILE_PATH="/var/log/nginx/access.log"
IMAGE="nginx:latest"

echo ${FILE_PATH##*/}
echo ${FILE_PATH##*.}
echo ${IMAGE/latest/1.25.3}
