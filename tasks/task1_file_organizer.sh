#!/bin/bash
# ============================================================================
# TOPSHIRIQ 1: Fayl Tartiblash (File Organizer)
# ============================================================================
# Maqsad: Berilgan papkadagi fayllarni kengaytmasi bo'yicha alohida
#          papkalarga tartiblash (masalan, .txt → txt/, .sh → sh/)
#
# Qo'llaniladigan mavzular:
#   - Loops (for, while)
#   - Conditionals (if/else)
#   - Parameter Expansion (kengaytmani ajratish)
#   - String Manipulation
#   - Fayllar bilan ishlash (mkdir, mv, test)
#
# Ishlatish:
#   ./task1_file_organizer.sh <papka_yo'li>
#   ./task1_file_organizer.sh ~/Downloads
# ============================================================================

set -euo pipefail

# --- Ranglar ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Yordamchi funksiyalar ---
log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_action()  { echo -e "${BLUE}[MOVE]${NC} $1"; }

# --- Argumentni tekshirish ---
if [[ $# -lt 1 ]]; then
    log_error "Foydalanish: $0 <papka_yo'li>"
    log_error "Misol: $0 ~/Downloads"
    exit 1
fi

TARGET_DIR="$1"

# Papka mavjudligini tekshirish
if [[ ! -d "$TARGET_DIR" ]]; then
    log_error "'$TARGET_DIR' papkasi topilmadi!"
    exit 1
fi

log_info "Tartiblash boshlandi: $TARGET_DIR"
echo "==========================================="

# --- Hisoblagichlar ---
moved=0
skipped=0
declare -A ext_count  # Har bir kengaytma uchun fayl soni (associative array)

# --- Fayllar bo'ylab aylanish ---
for filepath in "$TARGET_DIR"/*; do
    # Faqat fayllar bilan ishlash (papkalarni o'tkazib yuborish)
    if [[ ! -f "$filepath" ]]; then
        continue
    fi

    # Fayl nomini ajratish
    filename="${filepath##*/}"

    # Kengaytmani ajratish (Parameter Expansion)
    if [[ "$filename" == *.* ]]; then
        extension="${filename##*.}"
        extension="${extension,,}"  # kichik harfga o'tkazish
    else
        extension="boshqa"  # kengaytmasi yo'q fayllar
    fi

    # Maqsad papkani yaratish
    dest_dir="${TARGET_DIR}/${extension}"
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir"
        log_info "Papka yaratildi: ${extension}/"
    fi

    # Faylni ko'chirish
    mv "$filepath" "$dest_dir/"
    log_action "$filename → ${extension}/"
    ((moved++))

    # Statistikani yangilash
    ext_count["$extension"]=$(( ${ext_count["$extension"]:-0} + 1 ))
done

# --- Natija ---
echo ""
echo "==========================================="
log_info "Tartiblash yakunlandi!"
echo ""
echo "📊 Statistika:"
echo "   Ko'chirilgan fayllar: $moved"
echo ""

if [[ ${#ext_count[@]} -gt 0 ]]; then
    echo "   Kengaytmalar bo'yicha:"
    for ext in "${!ext_count[@]}"; do
        printf "     %-10s → %d ta fayl\n" ".$ext" "${ext_count[$ext]}"
    done
fi

echo "==========================================="
