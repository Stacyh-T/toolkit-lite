#!/bin/bash
# ============================================================
# apt-tools.sh — Installation des outils via apt
# toolkit v1.4
# ============================================================

REAL_USER="${SUDO_USER:-${USER:-$(id -un)}}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
REAL_HOME="${REAL_HOME:-$HOME}"

RED='\033[0;31m'; GREEN='\033[1;35m'; YELLOW='\033[0;35m'; CYAN='\033[1;34m'; NC='\033[0m'

install_apt() {
    local pkg="$1"
    if dpkg -s "$pkg" &>/dev/null; then
        echo -e "  \033[0;36m[~]\033[0m $pkg déjà installé"
        return
    fi
    local output
    if output=$(apt install -y "$pkg" 2>&1); then
        echo -e "  ${GREEN}[✓]${NC} $pkg installé"
    else
        echo -e "  ${RED}[✗]${NC} Échec : $pkg"
        echo "$output" | tail -15 | sed 's/^/      /'
    fi
}

echo ""
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "${CYAN}   Installation des outils apt — v1.1     ${NC}"
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo ""

apt update -qq

# ─────────────────────────────────────────────
# Utilitaires de base (en premier)
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Utilitaires de base${NC}"
install_apt pipx              # Gestionnaire d'outils Python isolés
install_apt tmux
install_apt git
install_apt jq
install_apt wget
install_apt unzip
install_apt golang-go
install_apt ruby
install_apt gem

# S'assurer que pipx est dans le PATH
su - "$REAL_USER" -c "pipx ensurepath" &>/dev/null || true

# ─────────────────────────────────────────────
# Recon & OSINT
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Recon & OSINT${NC}"
install_apt nmap
install_apt amass
install_apt dnsenum
install_apt whatweb
install_apt exiftool
install_apt sherlock
install_apt maltego
install_apt recon-ng
install_apt whois
install_apt dnsutils      # dig, nslookup, host

# ─────────────────────────────────────────────
# Web
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Web${NC}"
install_apt burpsuite
install_apt zaproxy
install_apt ffuf
install_apt gobuster
install_apt feroxbuster
install_apt nikto
install_apt curl
install_apt dirb
install_apt wfuzz
install_apt sqlmap
install_apt wafw00f
install_apt xsser
install_apt clamav        # scan AV côté upload + freshclam pour les signatures

# ─────────────────────────────────────────────
# Réseau & Enumération
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Réseau & Enumération${NC}"
install_apt netcat-traditional
install_apt hydra
install_apt enum4linux
install_apt nbtscan
install_apt onesixtyone
install_apt snmp
install_apt macchanger
install_apt wireshark
install_apt tcpdump
install_apt ncat
install_apt socat
install_apt arp-scan
install_apt smbmap
install_apt smbclient
install_apt samba-common-bin   # fournit rpcclient
install_apt rpcbind            # fournit rpcinfo
install_apt nfs-common         # fournit showmount
install_apt ident-user-enum
install_apt cewl
install_apt wpscan
install_apt fierce
install_apt tnscmd10g
install_apt ldap-utils
install_apt hash-identifier

# ─────────────────────────────────────────────
# Bases de données
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Bases de données${NC}"
install_apt default-mysql-client
install_apt postgresql-client

# ─────────────────────────────────────────────
# Passwords & Brute Force
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Passwords & Brute Force${NC}"
install_apt hashcat
install_apt john
install_apt crunch
install_apt medusa
install_apt ncrack

# ─────────────────────────────────────────────
# Reverse Engineering — Analyse statique
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Reverse Engineering${NC}"
install_apt gdb
install_apt binutils         # readelf, objdump, strings, nm, file
install_apt strace
install_apt ltrace
install_apt binwalk
install_apt upx-ucl
install_apt radare2

# ─────────────────────────────────────────────
# Exploitation
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Exploitation${NC}"
install_apt metasploit-framework

echo ""
echo -e "${GREEN}[✓] Installation apt terminée.${NC}"
