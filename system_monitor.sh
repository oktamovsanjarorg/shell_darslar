#!/bin/bash
# Server resurslarini monitoring qilish uchun mini skript

echo "=========================================="
echo "         TIZIM MONITORINGI                "
echo "=========================================="
echo "Sana: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Host: $(hostname)"
echo "Yadro (Kernel): $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "------------------------------------------"
echo "Xotira (RAM) holati:"
free -h | awk 'NR==1{print $0} NR==2{print $0}'
echo "------------------------------------------"
echo "Disk (Root) holati:"
df -h / | awk 'NR==1{print $0} NR==2{print $0}'
echo "=========================================="
