#!/bin/bash

# ============================================================
#   TOOLKIT INSTALLER — v1.4.0
#   Compatible: Kali Linux / Parrot OS
#   Usage: sudo ./install.sh
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIGS_INSTALLED=false

# ── Résolution du vrai utilisateur ───────────────────────────
REAL_USER="${SUDO_USER:-${USER:-$(id -un)}}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
REAL_HOME="${REAL_HOME:-$HOME}"

export REAL_USER
export REAL_HOME

# ── Journal d'installation ───────────────────────────────────
# Capture tout ce qui s'affiche (succès [✓] / échecs [✗] inclus,
# sans les codes couleur) dans un fichier log horodaté — utile
# pour le support si une installation ne se passe pas comme prévu.
LOG_FILE="$REAL_HOME/toolkit-install-$(date +%Y%m%d-%H%M%S).log"
export LOG_FILE
exec > >(tee >(sed -r 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE")) 2>&1
{
  echo "=== toolkit lite — installation du $(date '+%d/%m/%Y %H:%M:%S') ==="
  echo "Utilisateur : $REAL_USER (home: $REAL_HOME)"
  echo ""
} >> "$LOG_FILE"

# ── Taille moyenne par outil (ajustable) ─────────────────────
AVG_APT_MB=25
AVG_GITHUB_MB=20
SIZE_WORDLISTS=1200
SIZE_CONFIGS=1

# ── Calcul dynamique ─────────────────────────────────────────
NB_APT=$(grep -c "install_apt" "$TOOLKIT_DIR/setup/apt-tools.sh" 2>/dev/null || echo 0)
NB_GITHUB=$(grep -c "clone_tool\|install_category_github" "$TOOLKIT_DIR/setup/git-tools.sh" 2>/dev/null || echo 0)
SIZE_APT=$(( NB_APT * AVG_APT_MB ))
SIZE_GITHUB=$(( NB_GITHUB * AVG_GITHUB_MB ))

# ── APT update (une seule fois, au lancement) ────────────────
APT_UPDATED=false

apt_update() {
    if [ "$APT_UPDATED" = false ]; then
        echo -e "\n${CYAN}[*] Mise à jour des dépôts APT...${NC}"
        apt-get update -qq && echo -e "${GREEN}[✓] APT à jour.${NC}"
        APT_UPDATED=true
    fi
}

# ── Fonctions affichage ──────────────────────────────────────
banner() {
  echo -e "${CYAN}"
  echo "  ████████╗ ██████╗  ██████╗ ██╗     ██╗  ██╗██╗████████╗"
  echo "     ██╔══╝██╔═══██╗██╔═══██╗██║     ██║ ██╔╝██║╚══██╔══╝"
  echo "     ██║   ██║   ██║██║   ██║██║     █████╔╝ ██║   ██║   "
  echo "     ██║   ██║   ██║██║   ██║██║     ██╔═██╗ ██║   ██║   "
  echo "     ██║   ╚██████╔╝╚██████╔╝███████╗██║  ██╗██║   ██║   "
  echo "     ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝   "
  echo -e "${NC}"
  echo -e "${YELLOW}  Cybersecurity Toolkit Installer — v1.1 — Kali/Parrot${NC}"
  echo -e "${CYAN}  Utilisateur détecté : ${GREEN}$REAL_USER${NC} ${CYAN}(home: ${GREEN}$REAL_HOME${NC}${CYAN})${NC}"
  echo ""
}

step() { echo -e "\n${CYAN}[*] ========================================${NC}\n${CYAN}[*] ÉTAPE : $1${NC}\n${CYAN}[*] ========================================${NC}"; }
ok()   { echo -e "${GREEN}[✓] Succès : $1${NC}"; }
warn() { echo -e "${YELLOW}[!] Avertissement : $1${NC}"; }
fail() { echo -e "${RED}[✗] Erreur : $1${NC}"; }
info() { echo -e "${YELLOW}[>] $1${NC}"; }

# Exécute une commande (chaîne shell) : silencieux si succès, affiche
# le détail (dernières lignes de sortie) si échec.
run_cmd() {
  local label="$1" cmd="$2"
  local output rc
  output=$(eval "$cmd" 2>&1)
  rc=$?
  if [ $rc -eq 0 ]; then
    ok "$label"
  else
    fail "$label"
    echo "$output" | tail -15 | sed 's/^/      /'
  fi
  return $rc
}

# ── Résumé espace disque ─────────────────────────────────────
show_size_summary() {
  local available_mb
  available_mb=$(df -m "$REAL_HOME" | awk 'NR==2 {print $4}')
  local available_gb=$(( available_mb / 1024 ))
  local total=$(( SIZE_APT + SIZE_GITHUB + SIZE_WORDLISTS + SIZE_CONFIGS ))
  local total_gb=$(( total / 1024 ))

  local l_apt=$(printf "%-30s" "Outils apt   (${NB_APT} x ${AVG_APT_MB}Mo)")
  local v_apt=$(printf "%-22s" "~${SIZE_APT} Mo")
  local l_git=$(printf "%-30s" "Outils GitHub (${NB_GITHUB} x ${AVG_GITHUB_MB}Mo)")
  local v_git=$(printf "%-22s" "~${SIZE_GITHUB} Mo")
  local l_wrd=$(printf "%-30s" "Wordlists (SecLists+rockyou)")
  local v_wrd=$(printf "%-22s" "~${SIZE_WORDLISTS} Mo")
  local l_cfg=$(printf "%-30s" "Configs (dotfiles)")
  local v_cfg=$(printf "%-22s" "~${SIZE_CONFIGS} Mo")
  local l_tot=$(printf "%-30s" "TOTAL")
  local v_tot=$(printf "%-22s" "~${total} Mo (~${total_gb} Go)")
  local l_dis=$(printf "%-30s" "Disponible sur $REAL_HOME")
  local v_dis=$(printf "%-22s" "~${available_mb} Mo (~${available_gb} Go)")

  echo -e "${CYAN}  ┌─────────────────────────────────────────────────────────┐${NC}"
  echo -e "${CYAN}  │                Taille estimée du toolkit                │${NC}"
  echo -e "${CYAN}  ├────────────────────────────────┬────────────────────────┤${NC}"
  echo -e "${CYAN}  │${NC} ${l_apt} ${CYAN}│${NC} ${YELLOW}${v_apt}${NC} ${CYAN}│${NC}"
  echo -e "${CYAN}  │${NC} ${l_git} ${CYAN}│${NC} ${YELLOW}${v_git}${NC} ${CYAN}│${NC}"
  echo -e "${CYAN}  │${NC} ${l_wrd} ${CYAN}│${NC} ${YELLOW}${v_wrd}${NC} ${CYAN}│${NC}"
  echo -e "${CYAN}  │${NC} ${l_cfg} ${CYAN}│${NC} ${YELLOW}${v_cfg}${NC} ${CYAN}│${NC}"
  echo -e "${CYAN}  ├────────────────────────────────┼────────────────────────┤${NC}"
  echo -e "${CYAN}  │${NC} ${GREEN}${l_tot}${NC} ${CYAN}│${NC} ${GREEN}${v_tot}${NC} ${CYAN}│${NC}"
  echo -e "${CYAN}  ├────────────────────────────────┼────────────────────────┤${NC}"
  echo -e "${CYAN}  │${NC} ${l_dis} ${CYAN}│${NC} ${GREEN}${v_dis}${NC} ${CYAN}│${NC}"
  echo -e "${CYAN}  └────────────────────────────────┴────────────────────────┘${NC}"
  echo ""
}

# ── Vérification espace disque ───────────────────────────────
check_disk_space() {
  local required_mb="$1"
  local available_mb
  available_mb=$(df -m "$REAL_HOME" | awk 'NR==2 {print $4}')

  if [ "$available_mb" -lt "$required_mb" ]; then
    fail "Espace insuffisant ! Requis : ~${required_mb} Mo — Disponible : ${available_mb} Mo."
    fail "Libère de l'espace ou choisis une installation partielle."
    exit 1
  elif [ "$available_mb" -lt $(( required_mb * 2 )) ]; then
    warn "Espace limite (~${available_mb} Mo disponible pour ~${required_mb} Mo requis)."
    read -rp "  Continuer quand même ? [o/N] : " confirm
    [[ "$confirm" =~ ^[oO]$ ]] || exit 0
  else
    ok "Espace suffisant (${available_mb} Mo disponible)."
  fi
}

check_root() {
  if [ "$EUID" -ne 0 ]; then
    warn "Certaines installations nécessitent sudo."
    warn "Relance avec: sudo ./install.sh"
    echo ""
  fi
}

# ── Installation par catégorie (apt) ─────────────────────────
install_category_apt() {
  local category="$1"
  local tools=("${@:2}")
  step "Installation APT — $category"
  apt_update
  for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null || dpkg -s "$tool" &>/dev/null 2>&1; then
      echo -e "\033[0;36m[~]\033[0m L'outil '$tool' est déjà installé — ignoré."
    else
      run_cmd "'$tool' installé" "apt-get install -y '$tool'"
    fi
  done
}

# ── Installation par catégorie (GitHub) ──────────────────────
install_category_github() {
  local category="$1"
  shift
  local pairs=("$@")
  step "Installation GitHub — $category"
  for pair in "${pairs[@]}"; do
    local name="${pair%%|*}"
    local url="${pair##*|}"
    local dest="$REAL_HOME/tools/$name"
    mkdir -p "$REAL_HOME/tools"
    if [ -d "$dest" ]; then
      run_cmd "'$name' mis à jour" "git -C '$dest' pull"
    else
      run_cmd "'$name' cloné dans $dest" "git clone --depth=1 '$url' '$dest' && chown -R '$REAL_USER':'$REAL_USER' '$dest'"
    fi
  done
}

run_step() {
  local label="$1"
  local script="$2"
  apt_update
  step "$label"
  if bash "$TOOLKIT_DIR/$script"; then
    ok "Script $label terminé."
  else
    fail "Le script $label a échoué — vérifie $script"
  fi
  # Activer le flag si les configs ont été installées
  if [ "$label" = "Configs" ]; then
    CONFIGS_INSTALLED=true
  fi
}

# ── Menu principal ────────────────────────────────────────────
main_menu() {
  echo -e "${BOLD}  Que veux-tu installer ?${NC}"
  echo ""
  echo -e "  [1] ${GREEN}Tout${NC}                    ~$(( SIZE_APT + SIZE_GITHUB + SIZE_WORDLISTS + SIZE_CONFIGS )) Mo"
  echo -e "  [2] ${CYAN}Par catégorie${NC}           Choisir les thèmes"
  echo -e "  [3] ${YELLOW}Wordlists${NC}               ~${SIZE_WORDLISTS} Mo"
  echo -e "  [4] ${YELLOW}Configs${NC}                 ~${SIZE_CONFIGS} Mo  (.zshrc, tmux)"
  echo ""
  echo -e "  ${BOLD}🔒 Modules avancés (Reverse Engineering, IoT & WiFi, Cloud & Mobile,${NC}"
  echo -e "  ${BOLD}   Active Directory, API & GraphQL) : voir toolkit PRO.${NC}"
  echo ""
  read -rp "  Choix [1-4] : " choice
  echo ""

  case $choice in
    1)
      check_disk_space $(( SIZE_APT + SIZE_GITHUB + SIZE_WORDLISTS + SIZE_CONFIGS ))
      apt_update
      install_all
      run_step "Wordlists"  "setup/wordlists.sh"
      run_step "Configs"    "setup/configs.sh"
      ;;
    2) category_menu ;;
    3)
      check_disk_space "$SIZE_WORDLISTS"
      run_step "Wordlists" "setup/wordlists.sh"
      ;;
    4)
      check_disk_space "$SIZE_CONFIGS"
      run_step "Configs" "setup/configs.sh"
      ;;
    *) fail "Choix invalide."; exit 1 ;;
  esac
}

# ── Menu par catégorie ────────────────────────────────────────
category_menu() {
  echo -e "${BOLD}  Choisis les catégories à installer :${NC}"
  echo -e "  ${CYAN}(plusieurs choix possibles, ex: 1 3 5)${NC}"
  echo ""
  echo "  [1]  Recon & OSINT"
  echo "  [2]  OSINT — Identités & Fuites       (holehe, trufflehog, phoneinfroga...)"
  echo "  [3]  Web Security"
  echo "  [4]  Network"
  echo "  [5]  Password Cracking                (hashcat, john, medusa, ncrack...)"
  echo "  [6]  Post-Exploitation"
  echo "  [7]  PrivEsc Windows                  (GodPotato, PrintSpoofer, JuicyPotato)"
  echo "  [8]  Pivoting & Tunneling"
  echo "  [9]  Forensics"
  echo "  [10] Exploit (Metasploit)"
  echo "  [11] Utilitaires (tmux, git, jq…)"
  echo "  [12] Active Directory              (BloodHound, Kerbrute, NetExec, Responder...)"
  echo "  [13] API & GraphQL                 (graphw00f, graphql-cop, InQL)"
  echo "  [0]  Wordlists + Configs"
  echo ""
  read -rp "  Tes choix : " -a choices
  echo ""

  apt_update

  for c in "${choices[@]}"; do
    case $c in
      1)  install_recon ;;
      2)  install_osint_identity ;;
      3)  install_web ;;
      4)  install_network ;;
      5)  install_passwords ;;
      6)  install_postexploit ;;
      7)  install_privesc ;;
      8)  install_pivoting ;;
      9)  install_forensics ;;
      10) install_exploit ;;
      11) install_utils ;;
      12) install_ad ;;
      13) install_api ;;
      0)
        run_step "Wordlists" "setup/wordlists.sh"
        run_step "Configs"   "setup/configs.sh"
        ;;
      *) warn "Catégorie '$c' inconnue — ignorée" ;;
    esac
  done
}

# ── Définition des catégories ─────────────────────────────────

install_recon() {
  install_category_apt "Recon & OSINT" \
    nmap amass recon-ng maltego sherlock dnsenum whatweb exiftool whois dnsutils
  install_category_github "Recon & OSINT" \
    "spiderfoot|https://github.com/smicallef/spiderfoot" \
    "datasploit|https://github.com/DataSploit/datasploit" \
    "photon|https://github.com/s0md3v/Photon" \
    "social-analyzer|https://github.com/qeeqbox/social-analyzer" \
    "theHarvester|https://github.com/laramies/theHarvester"
}

install_osint_identity() {
  install_category_github "OSINT — Identités & Fuites" \
    "holehe|https://github.com/megadose/holehe" \
    "trufflehog|https://github.com/trufflesecurity/trufflehog" \
    "cupp|https://github.com/Mebus/cupp" \
    "username-anarchy|https://github.com/urbanadventurer/username-anarchy"
  step "OSINT — pipx"
  run_cmd "h8mail installé" "su - '$REAL_USER' -c 'pipx install h8mail'"
  step "OSINT — Outils Go"
  run_cmd "phoneinfroga installé" "go install github.com/sundowndev/phoneinfoga/v2@latest"
  run_cmd "waybackurls installé" "go install github.com/tomnomnom/waybackurls@latest"
}

install_web() {
  install_category_apt "Web Security" \
    burpsuite zaproxy ffuf gobuster feroxbuster nikto curl dirb wfuzz sqlmap wafw00f xsser clamav
  install_category_github "Web Security" \
    "xsstrike|https://github.com/s0md3v/XSStrike" \
    "brutexss|https://github.com/rajeshmajumdar/BruteXSS" \
    "gopherus|https://github.com/tarunkant/Gopherus" \
    "drupwn|https://github.com/immunIT/drupwn" \
    "droopescan|https://github.com/SamJoan/droopescan" \
    "dirsearch|https://github.com/maurosoria/dirsearch"
  step "Web Security — pipx"
  run_cmd "inql installé" "su - '$REAL_USER' -c 'pipx install inql'"
}

install_network() {
  install_category_apt "Network" \
    netcat-traditional hydra enum4linux nbtscan onesixtyone snmp macchanger \
    wireshark tcpdump ncat socat arp-scan smbmap smbclient samba-common-bin \
    rpcbind nfs-common ident-user-enum cewl wpscan fierce tnscmd10g ldap-utils \
    hash-identifier
  install_category_github "Network" \
    "impacket|https://github.com/fortra/impacket" \
    "smtp-user-enum|https://github.com/cytopia/smtp-user-enum" \
    "svmap|https://github.com/EnableSecurity/sipvicious"
  step "Network — Go"
  if ! command -v massdns &>/dev/null; then
    run_cmd "massdns installé" "apt-get install -y massdns -qq"
  fi
  run_cmd "puredns installé" "go install github.com/d3mondev/puredns/v2@latest"
}

install_passwords() {
  install_category_apt "Password Cracking" \
    hashcat john crunch medusa ncrack
  install_category_github "Password Cracking — Génération de wordlists" \
    "wister|https://github.com/cycurity/wister" \
    "kwprocessor|https://github.com/hashcat/kwprocessor"
  step "Password Cracking — post-installation"
  info "kwprocessor nécessite : cd ~/tools/kwprocessor && make"
}

install_ad() {
  step "Active Directory"
  install_category_apt "Active Directory" ldap-utils
  run_cmd "bloodhound-ce installé" "su - '$REAL_USER' -c 'pipx install bloodhound-ce'"
  run_cmd "ldapdomaindump installé" "su - '$REAL_USER' -c 'pipx install ldapdomaindump'"
  run_cmd "certipy-ad installé" "su - '$REAL_USER' -c 'pipx install certipy-ad'"
  run_cmd "netexec installé" "su - '$REAL_USER' -c 'pipx install git+https://github.com/Pennyw0rth/NetExec'"
  run_cmd "kerbrute installé" "go install github.com/ropnop/kerbrute@latest"
  install_category_github "Active Directory" \
    "Responder|https://github.com/lgandx/Responder"
  warn "Rubeus (Windows/.NET) et Active Directory (service Windows Server) n'ont pas d'équivalent Linux"
}

install_api() {
  step "API & GraphQL"
  install_category_apt "API & GraphQL" jq
  install_category_github "API & GraphQL" \
    "graphw00f|https://github.com/dolevf/graphw00f" \
    "graphql-cop|https://github.com/dolevf/graphql-cop"
  run_cmd "inql installé" "su - '$REAL_USER' -c 'pipx install inql'"
}

install_postexploit() {
  install_category_github "Post-Exploitation" \
    "PEASS-ng|https://github.com/peass-ng/PEASS-ng" \
    "pwncat|https://github.com/calebstewart/pwncat" \
    "evil-winrm|https://github.com/Hackplayers/evil-winrm" \
    "mimikatz|https://github.com/gentilkiwi/mimikatz" \
    "crackmapexec|https://github.com/byt3bl33d3r/CrackMapExec" \
    "bashfuscator|https://github.com/Bashfuscator/Bashfuscator"
}

install_privesc() {
  install_category_github "PrivEsc Windows" \
    "GodPotato|https://github.com/BeichenDream/GodPotato" \
    "PrintSpoofer|https://github.com/itm4n/PrintSpoofer" \
    "JuicyPotato|https://github.com/ohpe/juicy-potato"
}

install_pivoting() {
  install_category_github "Pivoting & Tunneling" \
    "chisel|https://github.com/jpillora/chisel" \
    "ligolo-ng|https://github.com/nicocha30/ligolo-ng" \
    "proxychains-ng|https://github.com/rofl0r/proxychains-ng" \
    "sshuttle|https://github.com/sshuttle/sshuttle"
}

install_forensics() {
  install_category_github "Forensics" \
    "autopsy|https://github.com/sleuthkit/autopsy" \
    "volatility3|https://github.com/volatilityfoundation/volatility3" \
    "plaso|https://github.com/log2timeline/plaso"
}

install_exploit() {
  install_category_apt "Exploit" \
    metasploit-framework
}

install_utils() {
  install_category_apt "Utilitaires" \
    tmux git jq wget unzip golang-go pipx ruby gem
  # S'assurer que pipx est dans le PATH du vrai utilisateur
  su - "$REAL_USER" -c "pipx ensurepath" &>/dev/null || true
}

install_all() {
  # ⚠️ install_utils EN PREMIER — installe golang-go, pipx et git
  # nécessaires pour les étapes suivantes (go install, pipx install, git clone)
  install_utils
  install_recon
  install_osint_identity
  install_web
  install_network
  install_passwords
  install_postexploit
  install_privesc
  install_pivoting
  install_forensics
  install_exploit
  install_ad
  install_api
}

# ── MAIN ─────────────────────────────────────────────────────
banner
check_root
show_size_summary
main_menu

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Toolkit prêt.${NC}"
echo -e "${GREEN}  Outils dans : $REAL_HOME/tools/${NC}"
if [ "$CONFIGS_INSTALLED" = true ]; then
  echo -e "${GREEN}  Lance un nouveau terminal pour activer l'environnement.${NC}"
fi
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""

# ── Résumé du log ─────────────────────────────────────────────
NB_OK=$(grep -c '\[✓\]' "$LOG_FILE" 2>/dev/null || echo 0)
NB_FAIL=$(grep -c '\[✗\]' "$LOG_FILE" 2>/dev/null || echo 0)
echo -e "${CYAN}  Résumé : ${GREEN}${NB_OK} succès${NC} / ${RED}${NB_FAIL} échec(s)${NC}"
echo -e "${CYAN}  Journal complet : ${YELLOW}${LOG_FILE}${NC}"
if [ "$NB_FAIL" -gt 0 ]; then
  echo -e "${YELLOW}  Ce qui a échoué :${NC}"
  grep '\[✗\]' "$LOG_FILE" | sed 's/^/    /'
fi
echo ""
