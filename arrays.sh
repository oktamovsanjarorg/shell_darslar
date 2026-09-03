#!/bin/bash
# Bash Arrays va Parameter Substitution amaliyoti

# 1. Massiv e'lon qilish
serverlar=("web-01" "db-01" "cache-01" "api-01")

echo "=== Serverlar ro'yxati ==="
echo "Barcha serverlar: ${serverlar[@]}"
echo "Serverlar soni: ${#serverlar[@]}"
echo "Birinchi server: ${serverlar[0]}"

# 2. Massivga yangi element qo'shish
serverlar+=("monitor-01")
echo "Yangi server qo'shilgach: ${serverlar[*]}"

# 3. Massiv bo'ylab sikl
echo -e "\n=== Serverlarni tekshirish ==="
for server in "${serverlar[@]}"; do
    echo "Status tekshirilmoqda: $server -> OK"
done

# 4. Qism-massiv (Slice) olish
echo -e "\n=== Dastlabki 2 ta server ==="
echo "${serverlar[@]:0:2}"
