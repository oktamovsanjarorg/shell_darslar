#!/bin/bash
# Bash Functions (Funksiyalar va return status)

# Ranglar
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

check_service() {
    local service_name="$1"
    log_info "Xizmat tekshirilmoqda: $service_name"
    
    if systemctl is-active --quiet "$service_name" 2>/dev/null; then
        log_info "$service_name faol ishlamoqda."
        return 0
    else
        log_error "$service_name to'xtatilgan yoki topilmadi."
        return 1
    fi
}

# Test chaqirish
log_info "Tizim auditi boshlandi."
check_service "sshd" || true
log_info "Tekshiruv yakunlandi."
