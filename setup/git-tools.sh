#!/bin/bash
# ============================================================
# git-tools.sh — Installation des outils via GitHub
# toolkit v1.4
# ============================================================

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")
TOOLS="$REAL_HOME/tools"

RED='\033[0;31m'; GREEN='\033[1;35m'; YELLOW='\033[0;35m'; CYAN='\033[1;34m'; NC='\033[0m'

mkdir -p "$TOOLS"

# Exécute une commande (sous forme de chaîne shell) : silencieux si succès,
# affiche le détail (dernières lignes de sortie) si échec.
run_cmd() {
    local label="$1" cmd="$2"
    local output rc
    output=$(eval "$cmd" 2>&1)
    rc=$?
    if [ $rc -eq 0 ]; then
        echo -e "  ${GREEN}[✓]${NC} $label"
    else
        echo -e "  ${RED}[✗]${NC} Échec : $label"
        echo "$output" | tail -15 | sed 's/^/      /'
    fi
    return $rc
}

clone_tool() {
    local name="$1"
    local repo="$2"
    if [ -d "$TOOLS/$name" ]; then
        echo -e "  \033[0;36m[~]\033[0m $name déjà cloné — mise à jour..."
        git -C "$TOOLS/$name" pull -q 2>/dev/null || true
        return
    fi
    local output
    if output=$(git clone --depth=1 "$repo" "$TOOLS/$name" 2>&1); then
        echo -e "  ${GREEN}[✓]${NC} $name cloné"
    else
        echo -e "  ${RED}[✗]${NC} Échec : $name"
        echo "$output" | tail -15 | sed 's/^/      /'
    fi
}

pipx_install() {
    local pkg="$1"
    if su - "$REAL_USER" -c "pipx list 2>/dev/null" | grep -q "$pkg"; then
        echo -e "  \033[0;36m[~]\033[0m $pkg déjà installé via pipx"
        return
    fi
    local output
    if output=$(su - "$REAL_USER" -c "pipx install $pkg" 2>&1); then
        echo -e "  ${GREEN}[✓]${NC} $pkg installé"
    else
        echo -e "  ${RED}[✗]${NC} Échec : $pkg"
        echo "$output" | tail -15 | sed 's/^/      /'
    fi
}

pipx_install_local() {
    local name="$1"
    local tool_dir="$TOOLS/$name"
    if su - "$REAL_USER" -c "pipx list 2>/dev/null" | grep -q "$name"; then
        echo -e "  \033[0;36m[~]\033[0m $name déjà installé via pipx"
        return
    fi
    local output
    if output=$(su - "$REAL_USER" -c "pipx install $tool_dir" 2>&1); then
        echo -e "  ${GREEN}[✓]${NC} $name installé"
    else
        echo -e "  ${RED}[✗]${NC} Échec : $name"
        echo "$output" | tail -15 | sed 's/^/      /'
    fi
}

echo ""
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "${CYAN}   Installation GitHub tools — v1.1       ${NC}"
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "  Dossier cible : ${YELLOW}$TOOLS${NC}\n"

# ─────────────────────────────────────────────
# Vérification des dépendances
# ─────────────────────────────────────────────
echo -e "${YELLOW}[*] Vérification des dépendances...${NC}"

if ! command -v go &>/dev/null; then
    run_cmd "golang-go installé" "apt-get update -qq && apt-get install -y golang-go -qq"
else
    echo -e "  \033[0;36m[~]\033[0m Go déjà installé ($(go version | awk '{print $3}'))"
fi

if ! command -v pipx &>/dev/null; then
    run_cmd "pipx installé" "apt-get install -y pipx -qq && su - '$REAL_USER' -c 'pipx ensurepath'"
else
    echo -e "  \033[0;36m[~]\033[0m pipx déjà installé"
fi

if ! command -v git &>/dev/null; then
    run_cmd "git installé" "apt-get install -y git -qq"
else
    echo -e "  \033[0;36m[~]\033[0m git déjà installé"
fi

# ─────────────────────────────────────────────
# Recon & OSINT
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Recon & OSINT${NC}"
clone_tool "spiderfoot"      "https://github.com/smicallef/spiderfoot"
clone_tool "datasploit"      "https://github.com/DataSploit/datasploit"
clone_tool "photon"          "https://github.com/s0md3v/Photon"
clone_tool "social-analyzer" "https://github.com/qeeqbox/social-analyzer"
clone_tool "theHarvester"    "https://github.com/laramies/theHarvester"
if [ -f "$TOOLS/theHarvester/requirements.txt" ]; then
    run_cmd "theHarvester — dépendances installées" "su - '$REAL_USER' -c \"pip install -r '$TOOLS/theHarvester/requirements.txt' --break-system-packages\""
fi

# ─────────────────────────────────────────────
# OSINT — Identités & Fuites
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] OSINT — Identités & Fuites${NC}"
pipx_install holehe
clone_tool "trufflehog"      "https://github.com/trufflesecurity/trufflehog"
pipx_install h8mail
clone_tool "cupp"            "https://github.com/Mebus/cupp"
clone_tool "username-anarchy" "https://github.com/urbanadventurer/username-anarchy"

# Go tools
run_cmd "phoneinfroga installé" "go install github.com/sundowndev/phoneinfoga/v2@latest"
run_cmd "waybackurls installé" "go install github.com/tomnomnom/waybackurls@latest"

# ─────────────────────────────────────────────
# Web
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Web${NC}"
clone_tool "xsstrike"        "https://github.com/s0md3v/XSStrike"
clone_tool "brutexss"        "https://github.com/rajeshmajumdar/BruteXSS"
clone_tool "gopherus"        "https://github.com/tarunkant/Gopherus"
clone_tool "drupwn"          "https://github.com/immunIT/drupwn"
clone_tool "droopescan"      "https://github.com/SamJoan/droopescan"
clone_tool "dirsearch"       "https://github.com/maurosoria/dirsearch"
clone_tool "graphql-cop"     "https://github.com/dolevf/graphql-cop"
clone_tool "graphw00f"       "https://github.com/dolevf/graphw00f"
for d in dirsearch graphql-cop graphw00f; do
    if [ -f "$TOOLS/$d/requirements.txt" ]; then
        run_cmd "$d — dépendances installées" "su - '$REAL_USER' -c \"pip install -r '$TOOLS/$d/requirements.txt' --break-system-packages\""
    fi
done
pipx_install inql

# ─────────────────────────────────────────────
# Génération de wordlists
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Génération de wordlists${NC}"
clone_tool "wister"          "https://github.com/cycurity/wister"
if [ -f "$TOOLS/wister/requirements.txt" ]; then
    run_cmd "wister — dépendances installées" "su - '$REAL_USER' -c \"pip install -r '$TOOLS/wister/requirements.txt' --break-system-packages\""
fi
clone_tool "kwprocessor"     "https://github.com/hashcat/kwprocessor"
if [ -d "$TOOLS/kwprocessor" ]; then
    run_cmd "kwprocessor compilé" "su - '$REAL_USER' -c \"cd '$TOOLS/kwprocessor' && make\""
fi

# ─────────────────────────────────────────────
# Réseau
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Réseau${NC}"
clone_tool "impacket"        "https://github.com/fortra/impacket"
clone_tool "smtp-user-enum"  "https://github.com/cytopia/smtp-user-enum"
clone_tool "sipvicious"      "https://github.com/EnableSecurity/sipvicious"

if ! command -v massdns &>/dev/null; then
    run_cmd "massdns installé" "apt-get install -y massdns -qq"
fi
run_cmd "puredns installé" "go install github.com/d3mondev/puredns/v2@latest"

# ─────────────────────────────────────────────
# Post-Exploitation
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Post-Exploitation${NC}"
clone_tool "PEASS-ng"        "https://github.com/peass-ng/PEASS-ng"
clone_tool "evil-winrm"      "https://github.com/Hackplayers/evil-winrm"
clone_tool "mimikatz"        "https://github.com/gentilkiwi/mimikatz"
clone_tool "bashfuscator"    "https://github.com/Bashfuscator/Bashfuscator"

# pwncat via pipx
pipx_install pwncat-cs

# CrackMapExec via pipx
pipx_install crackmapexec

# Impacket via pipx
pipx_install_local "impacket"

# ─────────────────────────────────────────────
# Post-Exploitation — PrivEsc Windows
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] PrivEsc Windows${NC}"
clone_tool "GodPotato"       "https://github.com/BeichenDream/GodPotato"
clone_tool "PrintSpoofer"    "https://github.com/itm4n/PrintSpoofer"
clone_tool "JuicyPotato"     "https://github.com/ohpe/juicy-potato"

# ─────────────────────────────────────────────
# Pivoting & Tunneling
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Pivoting & Tunneling${NC}"
clone_tool "chisel"          "https://github.com/jpillora/chisel"
clone_tool "ligolo-ng"       "https://github.com/nicocha30/ligolo-ng"
clone_tool "proxychains-ng"  "https://github.com/rofl0r/proxychains-ng"
clone_tool "sshuttle"        "https://github.com/sshuttle/sshuttle"

# sshuttle via pipx
pipx_install sshuttle

run_cmd "legba installé" "go install github.com/evilsocket/legba@latest"

# ─────────────────────────────────────────────
# Reverse Engineering
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Reverse Engineering${NC}"
clone_tool "pwndbg"          "https://github.com/pwndbg/pwndbg"

if ! command -v diec &>/dev/null; then
    if command -v snap &>/dev/null; then
        run_cmd "detect-it-easy installé" "snap install detect-it-easy"
    else
        echo -e "  ${RED}[✗]${NC} snap indisponible — installer manuellement : https://github.com/horsicq/Detect-It-Easy/releases"
    fi
else
    echo -e "  \033[0;36m[~]\033[0m detect-it-easy déjà installé"
fi

# ─────────────────────────────────────────────
# Automatisation / IA offensive
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Automatisation / IA offensive${NC}"
if ! command -v ollama &>/dev/null; then
    run_cmd "Ollama installé" "curl -fsSL https://ollama.ai/install.sh | sh"
else
    echo -e "  \033[0;36m[~]\033[0m Ollama déjà installé"
fi
clone_tool "cai"             "https://github.com/aliasrobotics/cai"
if [ -d "$TOOLS/cai" ]; then
    run_cmd "cai installé" "su - '$REAL_USER' -c \"cd '$TOOLS/cai' && pip install . --break-system-packages\""
fi

# ─────────────────────────────────────────────
# Reverse Shells
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Reverse Shells${NC}"
clone_tool "revshells"       "https://github.com/0dayCTF/reverse-shell-generator"

# ─────────────────────────────────────────────
# Forensics
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[*] Forensics${NC}"
clone_tool "autopsy"         "https://github.com/sleuthkit/autopsy"
clone_tool "volatility3"     "https://github.com/volatilityfoundation/volatility3"
clone_tool "plaso"           "https://github.com/log2timeline/plaso"

# plaso via pipx
pipx_install plaso

echo ""
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "${GREEN}[✓] Clonage GitHub terminé.               ${NC}"
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}[!] Étapes post-installation requises :${NC}"
cat << 'EOF'
  cd ~/tools/pwndbg         && ./setup.sh
  cd ~/tools/bashfuscator   && pipx install .
  gem install evil-winrm
  cd ~/tools/chisel         && go build .
  cd ~/tools/ligolo-ng/cmd/proxy  && go build .
  cd ~/tools/proxychains-ng && ./configure && make && make install
EOF
