#!/bin/bash

# ============================================================
#  nmapscan.sh — Escáner Nmap para Kali Linux
#  Uso: ./nmapscan.sh <-l|-q> <ip/host>
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

BANNER="
${CYAN}${BOLD}
  ███╗   ██╗███╗   ███╗ █████╗ ██████╗      ██████╗ ██╗  ██╗
  ████╗  ██║████╗ ████║██╔══██╗██╔══██╗    ██╔════╝ ██║ ██╔╝
  ██╔██╗ ██║██╔████╔██║███████║██████╔╝    ╚█████╗  █████╔╝ 
  ██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝      ╚═══██╗ ██╔═██╗ 
  ██║ ╚████║██║ ╚═╝ ██║██║  ██║██║         ██████╔╝ ██║  ██╗
  ╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝         ╚═════╝  ╚═╝  ╚═╝
${NC}${YELLOW}                  Kali Linux Scanner v1.2${NC}
"

usage() {
    echo -e "${BANNER}"
    echo -e "${BOLD}Uso:${NC}"
    echo -e "  ${GREEN}$0 -l <ip/host>${NC}   → Modo Ruidoso (Loud): rápido y agresivo"
    echo -e "  ${GREEN}$0 -q <ip/host>${NC}   → Modo Silencioso (Quiet): furtivo y completo"
    echo ""
    echo -e "${BOLD}Ejemplos:${NC}"
    echo -e "  $0 -l 192.168.1.1"
    echo -e "  $0 -q 10.0.0.0/24"
    echo ""
    exit 1
}

# ── Validación de argumentos ────────────────────────────────
if [[ $# -ne 2 ]]; then
    usage
fi

MODE="$1"
TARGET="$2"

if [[ "$MODE" != "-l" && "$MODE" != "-q" ]]; then
    echo -e "${RED}[!] Modo inválido: $MODE${NC}"
    usage
fi

# ── Verificar que nmap esté instalado ───────────────────────
if ! command -v nmap &>/dev/null; then
    echo -e "${RED}[!] nmap no está instalado. Instálalo con: sudo apt install nmap${NC}"
    exit 1
fi

# ── Verificar permisos root (necesario para -sS, -O, etc.) ──
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}[!] Advertencia: algunos escaneos requieren privilegios root (sudo).${NC}"
    echo -e "${YELLOW}    Se recomienda ejecutar con: sudo $0 $*${NC}"
    echo ""
fi

# ── Nombre de archivo de salida ─────────────────────────────
DATE=$(date +%Y%m%d)
TIME=$(date +%H%M%S)

case "$MODE" in
    -l) FILENAME="nmap_loud_scan_${DATE}_${TIME}.txt" ;;
    -q) FILENAME="nmap_quiet_scan_${DATE}_${TIME}.txt" ;;
esac

# ── Función: escaneo LOUD ────────────────────────────────────
run_loud() {
    echo -e "${RED}[★] MODO RUIDOSO (LOUD) activado${NC}"
    echo -e "${YELLOW}[i] Rápido, agresivo, sin restricciones de velocidad.${NC}"
    echo -e "${CYAN}[i] Objetivo : ${BOLD}$TARGET${NC}"
    echo -e "${CYAN}[i] Salida   : ${BOLD}$FILENAME${NC}\n"

    NMAP_CMD="nmap -sS -sV -sC -O -A -p- -T5 --version-intensity 9 --script=default,vuln,auth,discovery,exploit --open -v $TARGET"

    echo -e "${BOLD}[>] Ejecutando:${NC} $NMAP_CMD\n"

    {
        echo "========================================================="
        echo "  NMAP SCAN REPORT — MODO LOUD"
        echo "  Objetivo  : $TARGET"
        echo "  Fecha     : $(date '+%Y-%m-%d %H:%M:%S')"
        echo "  Comando   : $NMAP_CMD"
        echo "========================================================="
        echo ""
        eval "$NMAP_CMD"
    } | tee "$FILENAME"
}

# ── Función: escaneo QUIET ───────────────────────────────────
run_quiet() {
    echo -e "${GREEN}[★] MODO SILENCIOSO (QUIET) activado${NC}"
    echo -e "${YELLOW}[i] Máxima potencia, mínima detección. Tarda más tiempo.${NC}"
    echo -e "${CYAN}[i] Objetivo : ${BOLD}$TARGET${NC}"
    echo -e "${CYAN}[i] Salida   : ${BOLD}$FILENAME${NC}\n"

    NMAP_CMD="nmap -sS -sV -sC -O -A -p- -T1 --version-intensity 9 -D RND:10 --data-length 25 --randomize-hosts --spoof-mac 0 --ttl 64 --scan-delay 2s --max-retries 3 --script=default,vuln,auth,discovery --open -f $TARGET"

    echo -e "${BOLD}[>] Ejecutando:${NC} $NMAP_CMD\n"

    {
        echo "========================================================="
        echo "  NMAP SCAN REPORT — MODO QUIET"
        echo "  Objetivo  : $TARGET"
        echo "  Fecha     : $(date '+%Y-%m-%d %H:%M:%S')"
        echo "  Comando   : $NMAP_CMD"
        echo "========================================================="
        echo ""
        eval "$NMAP_CMD"
    } | tee "$FILENAME"
}

# ── Banner y ejecución ───────────────────────────────────────
echo -e "$BANNER"

START=$(date +%s)

case "$MODE" in
    -l) run_loud ;;
    -q) run_quiet ;;
esac

END=$(date +%s)
ELAPSED=$((END - START))

echo ""
echo -e "${GREEN}[✔] Escaneo completado en ${BOLD}${ELAPSED}s${NC}"
echo -e "${GREEN}[✔] Resultados guardados en: ${BOLD}${FILENAME}${NC}"
