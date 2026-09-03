#!/bin/bash
# Parameter Expansion (O'zgaruvchilarni kengaytirish va default qiymatlar)

# 1. Default qiymat berish (agar o'rnatilmagan bo'lsa)
PORT="${APP_PORT:-8080}"
echo "Server porti: $PORT"

# 2. Xatolik bilan to'xtatish (agar o'zgaruvchi berilmagan bo'lsa)
# : "${DATABASE_URL:?DATABASE_URL muhit o'zgaruvchisi aniqlanmagan!}"

# 3. Prefiks / Sufiks olib tashlash
filepath="/var/log/nginx/access.log"
filename="${filepath##*/}"
dirname="${filepath%/*}"

echo "Fayl yo'li: $filepath"
echo "Fayl nomi: $filename"
echo "Papka: $dirname"
