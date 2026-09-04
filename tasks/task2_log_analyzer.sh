#!/bin/bash
# ============================================================================
# TOPSHIRIQ 2: Log Tahlilchi (Log Analyzer)
# ============================================================================
# Maqsad: Web server log faylini tahlil qilish va statistika chiqarish
#
# Qo'llaniladigan mavzular:
#   - grep, awk, sort, uniq (matn filtrlash)
#   - Arrays va Associative Arrays
#   - Functions
#   - Here document va redirection
#   - String Manipulation
#
# Ishlatish:
#   ./task2_log_analyzer.sh <log_fayl>
#   ./task2_log_analyzer.sh /var/log/nginx/access.log
#
# Agar log faylsiz ishga tushirilsa, test log yaratadi.
# ============================================================================

set -euo pipefail

# --- Ranglar ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Funksiyalar ---
print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}══════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}══════════════════════════════════════${NC}"
}

print_section() {
    echo ""
    echo -e "${YELLOW}── $1 ──${NC}"
}

# Test log fayl yaratish funksiyasi
generate_test_log() {
    local logfile="$1"
    local ips=("192.168.1.10" "10.0.0.5" "172.16.0.1" "192.168.1.10" "10.0.0.5"
               "203.0.113.50" "192.168.1.10" "10.0.0.5" "172.16.0.1" "203.0.113.50"
               "192.168.1.10" "10.0.0.99" "203.0.113.50" "10.0.0.5" "192.168.1.10")
    local pages=("/" "/about" "/login" "/api/users" "/dashboard"
                 "/login" "/" "/api/data" "/about" "/login"
                 "/dashboard" "/" "/api/users" "/login" "/")
    local codes=("200" "200" "200" "200" "301"
                 "404" "200" "500" "200" "403"
                 "200" "200" "200" "401" "200")
    local methods=("GET" "GET" "POST" "GET" "GET"
                   "GET" "GET" "GET" "GET" "POST"
                   "GET" "GET" "DELETE" "POST" "GET")

    echo "Test log fayl yaratilmoqda: $logfile"
    > "$logfile"  # faylni tozalash

    for i in "${!ips[@]}"; do
        # Apache/Nginx combined log formati
        echo "${ips[$i]} - - [04/Sep/2026:10:${i}0:00 +0500] \"${methods[$i]} ${pages[$i]} HTTP/1.1\" ${codes[$i]} 1024 \"-\" \"Mozilla/5.0\"" >> "$logfile"
    done

    echo -e "${GREEN}[OK]${NC} $logfile yaratildi (${#ips[@]} qator)"
}

# Umumiy so'rovlar sonini hisoblash
count_total_requests() {
    local logfile="$1"
    local total
    total=$(wc -l < "$logfile")
    echo "$total"
}

# IP bo'yicha eng faol mijozlar (Top N)
top_ips() {
    local logfile="$1"
    local top_n="${2:-5}"
    awk '{print $1}' "$logfile" | sort | uniq -c | sort -rn | head -n "$top_n"
}

# HTTP status kodlari taqsimoti
status_distribution() {
    local logfile="$1"
    awk '{print $9}' "$logfile" | sort | uniq -c | sort -rn
}

# Eng ko'p so'ralgan sahifalar
top_pages() {
    local logfile="$1"
    local top_n="${2:-5}"
    awk '{print $7}' "$logfile" | sort | uniq -c | sort -rn | head -n "$top_n"
}

# Xatoliklar (4xx va 5xx)
error_requests() {
    local logfile="$1"
    awk '$9 >= 400 {print $9, $7, $1}' "$logfile"
}

# HTTP methodlar statistikasi
method_stats() {
    local logfile="$1"
    awk -F'"' '{split($2, a, " "); print a[1]}' "$logfile" | sort | uniq -c | sort -rn
}

# ============================================================================
# ASOSIY DASTUR
# ============================================================================

# Log faylni aniqlash
if [[ $# -ge 1 ]]; then
    LOG_FILE="$1"
else
    LOG_FILE="/tmp/test_access.log"
    generate_test_log "$LOG_FILE"
fi

# Fayl tekshirish
if [[ ! -f "$LOG_FILE" ]]; then
    echo -e "${RED}[ERROR]${NC} '$LOG_FILE' fayli topilmadi!"
    exit 1
fi

print_header "📊 LOG TAHLILI: ${LOG_FILE##*/}"

# 1. Umumiy ma'lumot
print_section "Umumiy ma'lumot"
total=$(count_total_requests "$LOG_FILE")
echo "   Jami so'rovlar: $total"
echo "   Fayl hajmi: $(du -h "$LOG_FILE" | awk '{print $1}')"

# 2. Top IP lar
print_section "🏆 Eng faol IP manzillar (Top 5)"
echo ""
printf "   %-8s  %s\n" "So'rov" "IP manzil"
printf "   %-8s  %s\n" "------" "---------"
while read -r count ip; do
    percentage=$(( count * 100 / total ))
    printf "   %-8s  %-18s (%d%%)\n" "$count" "$ip" "$percentage"
done <<< "$(top_ips "$LOG_FILE" 5)"

# 3. Status kodlar
print_section "📋 HTTP Status kodlari"
echo ""
printf "   %-8s  %-6s  %s\n" "Soni" "Kod" "Holat"
printf "   %-8s  %-6s  %s\n" "----" "---" "-----"
while read -r count code; do
    case "$code" in
        2*) status_text="Muvaffaqiyatli"; color="$GREEN" ;;
        3*) status_text="Yo'naltirish";   color="$YELLOW" ;;
        4*) status_text="Mijoz xatosi";   color="$RED" ;;
        5*) status_text="Server xatosi";  color="$RED" ;;
        *)  status_text="Noma'lum";       color="$NC" ;;
    esac
    printf "   %-8s  ${color}%-6s${NC}  %s\n" "$count" "$code" "$status_text"
done <<< "$(status_distribution "$LOG_FILE")"

# 4. Eng ko'p so'ralgan sahifalar
print_section "📄 Eng mashhur sahifalar (Top 5)"
echo ""
printf "   %-8s  %s\n" "So'rov" "Sahifa"
printf "   %-8s  %s\n" "------" "------"
while read -r count page; do
    printf "   %-8s  %s\n" "$count" "$page"
done <<< "$(top_pages "$LOG_FILE" 5)"

# 5. HTTP metodlar
print_section "🔧 HTTP Metodlar"
echo ""
while read -r count method; do
    printf "   %-8s  %s\n" "$count" "$method"
done <<< "$(method_stats "$LOG_FILE")"

# 6. Xatoliklar
print_section "⚠️  Xatoliklar (4xx / 5xx)"
echo ""
errors=$(error_requests "$LOG_FILE")
if [[ -z "$errors" ]]; then
    echo -e "   ${GREEN}Xatolik topilmadi!${NC}"
else
    printf "   %-6s  %-20s  %s\n" "Kod" "Sahifa" "IP"
    printf "   %-6s  %-20s  %s\n" "---" "------" "--"
    while read -r code page ip; do
        printf "   ${RED}%-6s${NC}  %-20s  %s\n" "$code" "$page" "$ip"
    done <<< "$errors"
fi

echo ""
echo -e "${CYAN}══════════════════════════════════════${NC}"
echo -e "${GREEN}Tahlil yakunlandi!${NC}"
echo -e "${CYAN}══════════════════════════════════════${NC}"
