#!/bin/bash
# ============================================================================
# TOPSHIRIQ 4: Zaxira Nusxa Yaratuvchi (Backup Script)
# ============================================================================
# Maqsad: Berilgan papkaning zaxira nusxasini tar arxiv sifatida yaratish
#          (sana/vaqt bilan nomlangan, eski zaxiralarni tozalash)
#
# Qo'llaniladigan mavzular:
#   - Parameter Expansion (default qiymatlar, o'zgaruvchi tekshirish)
#   - Error Handling (set -euo pipefail, trap)
#   - date buyrug'i va sana formatlash
#   - tar arxivlash
#   - Fayl hajmi hisoblash
#   - Arithmetic operations
#   - getopts (optional argumentlar)
#   - Rotation (eski zaxiralarni o'chirish)
#
# Ishlatish:
#   ./task4_backup_script.sh -s <manba> -d <maqsad> [-k <saqlash_soni>]
#   ./task4_backup_script.sh -s ~/projects -d ~/backups -k 5
#   ./task4_backup_script.sh -s /etc/nginx    # standart sozlamalar bilan
# ============================================================================

set -euo pipefail

# --- Ranglar ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Sozlamalar (Default qiymatlar — Parameter Expansion) ---
SOURCE_DIR=""
BACKUP_DIR="${BACKUP_DEST:-/tmp/backups}"
KEEP_COUNT="${BACKUP_KEEP:-3}"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
LOG_FILE=""

# --- Yordamchi funksiyalar ---
log_info()  { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "${LOG_FILE:-/dev/null}"; }
log_warn()  { echo -e "${YELLOW}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "${LOG_FILE:-/dev/null}"; }
log_error() { echo -e "${RED}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "${LOG_FILE:-/dev/null}" >&2; }

# Foydalanish ko'rsatmasi
usage() {
    cat << EOF
Foydalanish: $(basename "$0") [tanlovlar]

Tanlovlar:
  -s <papka>    Zaxiralanishi kerak bo'lgan manba papka (majburiy)
  -d <papka>    Zaxira saqlanadigan papka (standart: /tmp/backups)
  -k <son>      Saqlanadigan zaxiralar soni (standart: 3)
  -h            Yordam ko'rsatish

Misollar:
  $(basename "$0") -s ~/projects -d ~/backups -k 5
  $(basename "$0") -s /etc/nginx
EOF
    exit 0
}

# Hajmni inson o'qiydigan formatga o'tkazish
human_size() {
    local bytes="$1"
    if [[ "$bytes" -ge 1073741824 ]]; then
        echo "$(( bytes / 1073741824 )) GB"
    elif [[ "$bytes" -ge 1048576 ]]; then
        echo "$(( bytes / 1048576 )) MB"
    elif [[ "$bytes" -ge 1024 ]]; then
        echo "$(( bytes / 1024 )) KB"
    else
        echo "${bytes} B"
    fi
}

# Eski zaxiralarni tozalash (rotation)
rotate_backups() {
    local backup_dir="$1"
    local prefix="$2"
    local keep="$3"

    # Mos zaxira fayllarini sanash
    local backup_count
    backup_count=$(find "$backup_dir" -maxdepth 1 -name "${prefix}_*.tar.gz" -type f 2>/dev/null | wc -l)

    if [[ "$backup_count" -le "$keep" ]]; then
        log_info "Zaxiralar soni ($backup_count) chegaradan ($keep) kam. Tozalash shart emas."
        return 0
    fi

    local to_delete=$(( backup_count - keep ))
    log_warn "Eski zaxiralar tozalanmoqda: $to_delete ta o'chiriladi"

    # Eng eski fayllarni topib o'chirish
    find "$backup_dir" -maxdepth 1 -name "${prefix}_*.tar.gz" -type f -printf '%T+ %p\n' | \
        sort | head -n "$to_delete" | while read -r _ filepath; do
            log_info "  O'chirildi: ${filepath##*/}"
            rm -f "$filepath"
        done
}

# Tozalash (trap uchun)
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Zaxiralash xatolik bilan yakunlandi! (exit code: $exit_code)"
    fi
    # Vaqtinchalik fayllarni tozalash (agar bo'lsa)
    rm -f "/tmp/backup_$$_temp" 2>/dev/null || true
}

trap cleanup EXIT

# ============================================================================
# ARGUMENTLARNI O'QISH (getopts)
# ============================================================================

while getopts "s:d:k:h" opt; do
    case "$opt" in
        s) SOURCE_DIR="$OPTARG" ;;
        d) BACKUP_DIR="$OPTARG" ;;
        k) KEEP_COUNT="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Majburiy argumentni tekshirish
if [[ -z "$SOURCE_DIR" ]]; then
    log_error "Manba papka (-s) ko'rsatilmagan!"
    echo ""
    usage
fi

# Manba papka mavjudligini tekshirish
if [[ ! -d "$SOURCE_DIR" ]]; then
    log_error "Manba papka topilmadi: $SOURCE_DIR"
    exit 1
fi

# KEEP_COUNT raqam ekanligini tekshirish
if ! [[ "$KEEP_COUNT" =~ ^[0-9]+$ ]]; then
    log_error "Saqlash soni (-k) raqam bo'lishi kerak: $KEEP_COUNT"
    exit 1
fi

# ============================================================================
# ZAXIRALASH JARAYONI
# ============================================================================

# Zaxira papkasini yaratish
mkdir -p "$BACKUP_DIR"

# Nom yaratish
dir_name="${SOURCE_DIR##*/}"
dir_name="${dir_name:-root}"  # agar / bo'lsa
archive_name="${dir_name}_${TIMESTAMP}.tar.gz"
archive_path="${BACKUP_DIR}/${archive_name}"

# Log fayl
LOG_FILE="${BACKUP_DIR}/backup.log"

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║        📦 ZAXIRA NUSXA YARATISH          ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

log_info "Manba:       $SOURCE_DIR"
log_info "Maqsad:      $BACKUP_DIR"
log_info "Fayl nomi:   $archive_name"
log_info "Max zaxira:  $KEEP_COUNT ta"
echo ""

# Manba papka hajmini hisoblash
source_size=$(du -sb "$SOURCE_DIR" 2>/dev/null | awk '{print $1}') || source_size=0
log_info "Manba hajmi: $(human_size "$source_size")"

# Fayllar sonini hisoblash
file_count=$(find "$SOURCE_DIR" -type f 2>/dev/null | wc -l)
log_info "Fayllar soni: $file_count"

echo ""
log_info "Arxivlash boshlandi..."

# tar arxiv yaratish
start_time=$(date +%s)

tar -czf "$archive_path" \
    -C "$(dirname "$SOURCE_DIR")" \
    "$(basename "$SOURCE_DIR")" \
    2>/dev/null

end_time=$(date +%s)
duration=$(( end_time - start_time ))

# Arxiv hajmi
archive_size=$(stat -c %s "$archive_path" 2>/dev/null) || archive_size=0

echo ""
log_info "✅ Zaxiralash muvaffaqiyatli yakunlandi!"
echo ""

# Natija jadvali
echo -e "${BOLD}📊 Natijalar:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  %-25s %s\n" "Arxiv fayl:" "$archive_name"
printf "  %-25s %s\n" "Arxiv hajmi:" "$(human_size "$archive_size")"
printf "  %-25s %s\n" "Asl hajmi:" "$(human_size "$source_size")"

# Siqilish nisbatini hisoblash
if [[ "$source_size" -gt 0 ]]; then
    ratio=$(( (source_size - archive_size) * 100 / source_size ))
    printf "  %-25s %s%%\n" "Siqilish:" "$ratio"
fi

printf "  %-25s %s soniya\n" "Vaqt:" "$duration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Eski zaxiralarni tozalash
echo ""
rotate_backups "$BACKUP_DIR" "$dir_name" "$KEEP_COUNT"

echo ""
log_info "Barcha jarayon yakunlandi! 🎉"
