#!/bin/bash
# ============================================================================
# TOPSHIRIQ 3: Foydalanuvchi Boshqaruvchisi (User Manager)
# ============================================================================
# Maqsad: Interaktiv menyu orqali foydalanuvchilarni boshqarish
#          (ro'yxat, qidirish, ma'lumot ko'rish, CSV eksport)
#
# Qo'llaniladigan mavzular:
#   - case statement (menyu tanlash)
#   - Functions (modulli kod yozish)
#   - Input validation (kiritishni tekshirish)
#   - while loop (menyu sikli)
#   - Arrays
#   - read buyrug'i
#   - /etc/passwd bilan ishlash
#   - Redirection va pipe
#
# Ishlatish:
#   ./task3_user_manager.sh
#
# Eslatma: Ba'zi buyruqlar faqat ma'lumotni o'qiydi, tizimga o'zgartirish
#          kiritmaydi — xavfsiz!
# ============================================================================

set -euo pipefail

# --- Ranglar ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Yordamchi funksiyalar ---
log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# Pause - davom etish uchun Enter
pause() {
    echo ""
    read -rp "Davom etish uchun Enter bosing..." _
}

# ============================================================================
# ASOSIY FUNKSIYALAR
# ============================================================================

# Menyuni ko'rsatish
show_menu() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║    👤 FOYDALANUVCHI BOSHQARUVCHISI       ║"
    echo "╠══════════════════════════════════════════╣"
    echo "║  1) Barcha foydalanuvchilar ro'yxati     ║"
    echo "║  2) Foydalanuvchini qidirish             ║"
    echo "║  3) Foydalanuvchi haqida batafsil        ║"
    echo "║  4) Tizim statistikasi                   ║"
    echo "║  5) Loginlar tarixini ko'rish            ║"
    echo "║  6) Foydalanuvchilarni CSV ga eksport    ║"
    echo "║  0) Chiqish                              ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 1) Barcha real foydalanuvchilar (UID >= 1000)
list_users() {
    echo -e "${BOLD}📋 Tizim foydalanuvchilari (UID ≥ 1000):${NC}"
    echo ""
    printf "  ${BOLD}%-20s %-8s %-8s %s${NC}\n" "Foydalanuvchi" "UID" "GID" "Shell"
    printf "  %-20s %-8s %-8s %s\n" "────────────" "───" "───" "─────"

    local count=0
    while IFS=: read -r username _ uid gid _ _ shell; do
        if [[ "$uid" -ge 1000 ]] && [[ "$shell" != */nologin ]] && [[ "$shell" != */false ]]; then
            printf "  %-20s %-8s %-8s %s\n" "$username" "$uid" "$gid" "$shell"
            ((count++))
        fi
    done < /etc/passwd

    echo ""
    log_info "Jami: $count ta faol foydalanuvchi"
}

# 2) Foydalanuvchini qidirish
search_user() {
    read -rp "Qidiruv so'zini kiriting: " query

    # Kiritmani tekshirish
    if [[ -z "$query" ]]; then
        log_error "Qidiruv so'zi bo'sh bo'lmasligi kerak!"
        return 1
    fi

    # Maxsus belgilarni tekshirish (xavfsizlik)
    if [[ "$query" =~ [^a-zA-Z0-9._-] ]]; then
        log_error "Faqat harflar, raqamlar, '.', '_', '-' ishlatish mumkin!"
        return 1
    fi

    echo ""
    echo -e "${BOLD}🔍 '$query' bo'yicha qidiruv natijalari:${NC}"
    echo ""

    local found=0
    while IFS=: read -r username _ uid _ fullname home shell; do
        if [[ "${username,,}" == *"${query,,}"* ]] || [[ "${fullname,,}" == *"${query,,}"* ]]; then
            echo "  👤 $username (UID: $uid)"
            echo "     Ism: ${fullname:-noma'lum}"
            echo "     Home: $home"
            echo "     Shell: $shell"
            echo ""
            ((found++))
        fi
    done < /etc/passwd

    if [[ "$found" -eq 0 ]]; then
        log_warn "Hech narsa topilmadi."
    else
        log_info "$found ta natija topildi."
    fi
}

# 3) Bitta foydalanuvchi haqida batafsil ma'lumot
user_details() {
    read -rp "Foydalanuvchi nomini kiriting: " username

    if [[ -z "$username" ]]; then
        log_error "Ism bo'sh bo'lmasligi kerak!"
        return 1
    fi

    # Foydalanuvchi mavjudligini tekshirish
    if ! id "$username" &>/dev/null; then
        log_error "'$username' foydalanuvchisi topilmadi!"
        return 1
    fi

    echo ""
    echo -e "${BOLD}📄 '$username' haqida ma'lumot:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # id buyrug'idan ma'lumot
    echo -e "  ${CYAN}ID ma'lumoti:${NC}"
    echo "    $(id "$username")"

    # /etc/passwd dan ma'lumot
    local user_line
    user_line=$(grep "^${username}:" /etc/passwd) || true
    if [[ -n "$user_line" ]]; then
        local home shell fullname
        home=$(echo "$user_line" | cut -d: -f6)
        shell=$(echo "$user_line" | cut -d: -f7)
        fullname=$(echo "$user_line" | cut -d: -f5)

        echo -e "  ${CYAN}To'liq ism:${NC} ${fullname:-ko'rsatilmagan}"
        echo -e "  ${CYAN}Home papka:${NC} $home"
        echo -e "  ${CYAN}Shell:${NC} $shell"

        # Home papka hajmi (agar mavjud bo'lsa)
        if [[ -d "$home" ]]; then
            local size
            size=$(du -sh "$home" 2>/dev/null | awk '{print $1}') || size="noma'lum"
            echo -e "  ${CYAN}Home hajmi:${NC} $size"
        fi
    fi

    # Guruhlar
    echo -e "  ${CYAN}Guruhlar:${NC}"
    groups "$username" 2>/dev/null | sed 's/.*: /    /'
}

# 4) Tizim statistikasi
system_stats() {
    echo -e "${BOLD}📊 Foydalanuvchilar statistikasi:${NC}"
    echo ""

    local total_users real_users system_users nologin_users
    total_users=$(wc -l < /etc/passwd)
    real_users=$(awk -F: '$3 >= 1000 && $7 !~ /nologin|false/' /etc/passwd | wc -l)
    system_users=$(awk -F: '$3 < 1000' /etc/passwd | wc -l)
    nologin_users=$(grep -c 'nologin\|/false' /etc/passwd) || nologin_users=0

    printf "  %-30s %s\n" "Jami foydalanuvchilar:" "$total_users"
    printf "  %-30s %s\n" "Real foydalanuvchilar:" "$real_users"
    printf "  %-30s %s\n" "Tizim foydalanuvchilari:" "$system_users"
    printf "  %-30s %s\n" "Nologin foydalanuvchilar:" "$nologin_users"

    echo ""
    echo -e "  ${CYAN}Shell taqsimoti:${NC}"
    awk -F: '{print $7}' /etc/passwd | sort | uniq -c | sort -rn | while read -r count shell; do
        printf "    %-8s %s\n" "$count" "$shell"
    done

    echo ""
    echo -e "  ${CYAN}Hozir tizimda:${NC}"
    who 2>/dev/null | while read -r line; do
        echo "    $line"
    done || echo "    (hech kim yo'q)"
}

# 5) Login tarixi
login_history() {
    echo -e "${BOLD}📜 Oxirgi 10 ta login:${NC}"
    echo ""

    if command -v last &>/dev/null; then
        last -n 10 2>/dev/null | head -n 10 || log_warn "Login tarixi mavjud emas."
    else
        log_warn "'last' buyrug'i topilmadi."
    fi
}

# 6) CSV ga eksport
export_csv() {
    local csv_file="${1:-/tmp/users_export.csv}"

    echo "username,uid,gid,fullname,home,shell" > "$csv_file"

    while IFS=: read -r username _ uid gid fullname home shell; do
        if [[ "$uid" -ge 1000 ]] && [[ "$shell" != */nologin ]] && [[ "$shell" != */false ]]; then
            echo "$username,$uid,$gid,\"${fullname:-}\",\"$home\",\"$shell\"" >> "$csv_file"
        fi
    done < /etc/passwd

    local count
    count=$(( $(wc -l < "$csv_file") - 1 ))
    log_info "CSV eksport qilindi: $csv_file ($count ta foydalanuvchi)"
}

# ============================================================================
# ASOSIY SIKL (Main Loop)
# ============================================================================

while true; do
    show_menu
    read -rp "Tanlov [0-6]: " choice

    case "$choice" in
        1) list_users    ;;
        2) search_user   ;;
        3) user_details  ;;
        4) system_stats  ;;
        5) login_history ;;
        6) export_csv    ;;
        0)
            echo ""
            log_info "Dasturdan chiqildi. Xayr!"
            exit 0
            ;;
        *)
            log_error "Noto'g'ri tanlov! 0-6 orasida raqam kiriting."
            ;;
    esac

    pause
done
