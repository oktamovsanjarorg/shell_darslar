#!/bin/bash
# ============================================================================
# TOPSHIRIQ 5: Xizmatlar Holati Dashboard (Service Dashboard)
# ============================================================================
# Maqsad: Tizim xizmatlari va resurslarini real-time monitoring qilish
#          (auto-refresh, rangli holat ko'rsatish, signal handling)
#
# Qo'llaniladigan mavzular:
#   - Functions (modulli arxitektura)
#   - Arrays (xizmatlar ro'yxati)
#   - Loops (monitoring sikli, for/while)
#   - Trap va Signal Handling (SIGINT, SIGTERM)
#   - String Manipulation va printf formatlash
#   - Arithmetic operations
#   - Command substitution
#   - /proc filesystem o'qish
#   - tput (terminal boshqaruvi)
#
# Ishlatish:
#   ./task5_service_dashboard.sh              # standart xizmatlar
#   ./task5_service_dashboard.sh -i 5         # 5 soniyada yangilanish
#   ./task5_service_dashboard.sh -s "nginx sshd docker"  # maxsus xizmatlar
#   ./task5_service_dashboard.sh -1           # bir marta ko'rsatish
# ============================================================================

set -uo pipefail

# --- Ranglar ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# --- Sozlamalar ---
INTERVAL=3
ONCE=false
SERVICES=("sshd" "NetworkManager" "docker" "nginx" "cronie" "bluetooth" "firewalld")

# --- Signal Handling (trap) ---
RUNNING=true

graceful_exit() {
    RUNNING=false
    echo ""
    echo ""
    echo -e "${GREEN}Dashboard to'xtatildi. Xayr! 👋${NC}"
    # Kursorni qaytarish
    tput cnorm 2>/dev/null || true
    exit 0
}

trap graceful_exit SIGINT SIGTERM

# --- Argumentlarni o'qish ---
while getopts "i:s:1h" opt; do
    case "$opt" in
        i) INTERVAL="$OPTARG" ;;
        s) IFS=' ' read -ra SERVICES <<< "$OPTARG" ;;
        1) ONCE=true ;;
        h)
            echo "Foydalanish: $(basename "$0") [-i interval] [-s \"xizmatlar\"] [-1]"
            echo "  -i <soniya>    Yangilanish oralig'i (standart: 3)"
            echo "  -s \"...\"       Xizmatlar ro'yxati (bo'sh joy bilan ajratilgan)"
            echo "  -1             Faqat bir marta ko'rsatish"
            exit 0
            ;;
        *) exit 1 ;;
    esac
done

# ============================================================================
# YORDAMCHI FUNKSIYALAR
# ============================================================================

# Progress bar yaratish
progress_bar() {
    local value="$1"
    local max="${2:-100}"
    local width="${3:-20}"

    local filled=$(( value * width / max ))
    local empty=$(( width - filled ))

    # Rang tanlash
    local color="$GREEN"
    if [[ "$value" -ge 90 ]]; then
        color="$RED"
    elif [[ "$value" -ge 70 ]]; then
        color="$YELLOW"
    fi

    printf "${color}"
    printf '█%.0s' $(seq 1 "$filled" 2>/dev/null) || true
    printf "${DIM}"
    printf '░%.0s' $(seq 1 "$empty" 2>/dev/null) || true
    printf "${NC}"
}

# CPU foizini olish
get_cpu_usage() {
    # /proc/stat dan olish (1 soniyalik o'rtacha)
    local cpu_line idle1 total1 idle2 total2
    cpu_line=$(head -1 /proc/stat)
    idle1=$(echo "$cpu_line" | awk '{print $5}')
    total1=$(echo "$cpu_line" | awk '{sum=0; for(i=2;i<=NF;i++) sum+=$i; print sum}')

    sleep 0.5

    cpu_line=$(head -1 /proc/stat)
    idle2=$(echo "$cpu_line" | awk '{print $5}')
    total2=$(echo "$cpu_line" | awk '{sum=0; for(i=2;i<=NF;i++) sum+=$i; print sum}')

    local idle_diff=$(( idle2 - idle1 ))
    local total_diff=$(( total2 - total1 ))

    if [[ "$total_diff" -gt 0 ]]; then
        echo $(( 100 - (idle_diff * 100 / total_diff) ))
    else
        echo 0
    fi
}

# RAM ma'lumotlarini olish
get_memory_info() {
    local total used available percent
    total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    available=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    used=$(( total - available ))
    percent=$(( used * 100 / total ))

    echo "$used $total $percent"
}

# Disk ma'lumotlarini olish
get_disk_info() {
    df -h / 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $3, $2, $5}'
}

# Xizmat holatini tekshirish
check_service_status() {
    local service="$1"

    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "active"
    elif systemctl is-enabled --quiet "$service" 2>/dev/null; then
        echo "inactive"
    else
        echo "not-found"
    fi
}

# Uptime ni formatlash
get_uptime() {
    local seconds
    seconds=$(awk '{print int($1)}' /proc/uptime)
    local days=$(( seconds / 86400 ))
    local hours=$(( (seconds % 86400) / 3600 ))
    local mins=$(( (seconds % 3600) / 60 ))

    if [[ "$days" -gt 0 ]]; then
        echo "${days}k ${hours}s ${mins}d"
    elif [[ "$hours" -gt 0 ]]; then
        echo "${hours}s ${mins}d"
    else
        echo "${mins}d"
    fi
}

# ============================================================================
# DASHBOARD CHIZISH
# ============================================================================

draw_dashboard() {
    # Ekranni tozalash (tput yoki clear)
    if ! $ONCE; then
        tput clear 2>/dev/null || clear
    fi

    local now
    now=$(date '+%Y-%m-%d %H:%M:%S')
    local uptime
    uptime=$(get_uptime)
    local hostname
    hostname=$(hostname)
    local load
    load=$(awk '{print $1, $2, $3}' /proc/loadavg)

    # Sarlavha
    echo -e "${BOLD}${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║              🖥️  TIZIM MONITORING DASHBOARD              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    printf "  ${DIM}Host:${NC} %-20s ${DIM}Vaqt:${NC} %s\n" "$hostname" "$now"
    printf "  ${DIM}Uptime:${NC} %-18s ${DIM}Load:${NC} %s\n" "$uptime" "$load"

    # ── TIZIM RESURSLARI ──
    echo ""
    echo -e "  ${BOLD}${YELLOW}── Tizim Resurslari ──${NC}"
    echo ""

    # CPU
    local cpu_percent
    cpu_percent=$(get_cpu_usage)
    printf "  ${CYAN}CPU:${NC}    ["
    progress_bar "$cpu_percent"
    printf "] %3d%%\n" "$cpu_percent"

    # RAM
    local mem_info mem_used mem_total mem_percent
    read -r mem_used mem_total mem_percent <<< "$(get_memory_info)"
    local mem_used_mb=$(( mem_used / 1024 ))
    local mem_total_mb=$(( mem_total / 1024 ))
    printf "  ${CYAN}RAM:${NC}    ["
    progress_bar "$mem_percent"
    printf "] %3d%%  (%d/%d MB)\n" "$mem_percent" "$mem_used_mb" "$mem_total_mb"

    # Disk
    local disk_used disk_total disk_percent
    read -r disk_used disk_total disk_percent <<< "$(get_disk_info)"
    printf "  ${CYAN}Disk /:${NC} ["
    progress_bar "$disk_percent"
    printf "] %3d%%  (%s/%s)\n" "$disk_percent" "$disk_used" "$disk_total"

    # ── XIZMATLAR ──
    echo ""
    echo -e "  ${BOLD}${YELLOW}── Xizmatlar Holati ──${NC}"
    echo ""
    printf "  ${BOLD}%-25s %s${NC}\n" "Xizmat" "Holat"
    printf "  %-25s %s\n" "─────────────────" "──────"

    local active_count=0
    local inactive_count=0
    local notfound_count=0

    for service in "${SERVICES[@]}"; do
        local status
        status=$(check_service_status "$service")

        case "$status" in
            active)
                printf "  %-25s ${GREEN}● faol${NC}\n" "$service"
                ((active_count++))
                ;;
            inactive)
                printf "  %-25s ${YELLOW}○ to'xtatilgan${NC}\n" "$service"
                ((inactive_count++))
                ;;
            not-found)
                printf "  %-25s ${RED}✗ topilmadi${NC}\n" "$service"
                ((notfound_count++))
                ;;
        esac
    done

    echo ""
    printf "  ${DIM}Jami: %d | ${GREEN}Faol: %d${NC} | ${YELLOW}To'xtatilgan: %d${NC} | ${RED}Topilmadi: %d${NC}\n" \
        "${#SERVICES[@]}" "$active_count" "$inactive_count" "$notfound_count"

    # ── TOP JARAYONLAR ──
    echo ""
    echo -e "  ${BOLD}${YELLOW}── Top 5 Jarayon (CPU bo'yicha) ──${NC}"
    echo ""
    printf "  ${BOLD}%-8s %-6s %-6s %s${NC}\n" "PID" "CPU%" "MEM%" "Buyruq"
    printf "  %-8s %-6s %-6s %s\n" "────" "────" "────" "──────"
    ps aux --sort=-%cpu 2>/dev/null | awk 'NR>1 && NR<=6 {printf "  %-8s %-6s %-6s %s\n", $2, $3, $4, $11}'

    # Footer
    echo ""
    if $ONCE; then
        echo -e "  ${DIM}Bir martalik rejim.${NC}"
    else
        echo -e "  ${DIM}Yangilanish: har ${INTERVAL}s | Chiqish: Ctrl+C${NC}"
    fi
}

# ============================================================================
# ASOSIY SIKL
# ============================================================================

# Kursorni yashirish (agar auto-refresh bo'lsa)
if ! $ONCE; then
    tput civis 2>/dev/null || true
fi

if $ONCE; then
    draw_dashboard
else
    while $RUNNING; do
        draw_dashboard
        # Uzilishga imkon beradigan sleep
        sleep "$INTERVAL" &
        wait $! 2>/dev/null || true
    done
fi
