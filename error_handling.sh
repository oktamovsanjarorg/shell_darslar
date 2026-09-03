#!/bin/bash
# Xatoliklarni ushlash va xavfsiz Bash rejimi (Unofficial Bash Strict Mode)

set -euo pipefail

# Trap yordamida tozalash (cleanup)
cleanup() {
    echo "Tozalash ishlari bajarilmoqda..."
    rm -f /tmp/test_temp_file.txt
    echo "Dastur yakunlandi."
}

trap cleanup EXIT

echo "Vaqtinchalik fayl yaratilmoqda..."
touch /tmp/test_temp_file.txt
echo "Fayl yaratildi: /tmp/test_temp_file.txt"
