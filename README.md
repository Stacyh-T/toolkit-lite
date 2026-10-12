# ⚡ toolkit v1.0.0

> Mon environnement de cybersécurité portable — Kali Linux / Parrot OS.

---

## 🔒 toolkit PRO

Une version **Pro** existe en complément, avec des modules avancés exclusifs (Reverse Engineering, IoT & WiFi, Cloud & Mobile) ainsi qu'une installation groupée Active Directory / API & GraphQL. Disponible sur [Gumroad](#).

---

## 🚀 Installation rapide

```bash
# Prérequis
git --version
ping -c 3 github.com
df -h ~               # prévoir ~1,5 Go libres minimum

# Installation
git clone https://github.com/Stacyh-T/toolkit.git ~/toolkit
cd ~/toolkit
chmod +x install.sh setup/*.sh scripts/*.sh
sudo ./install.sh
```

> 💡 Le script détecte automatiquement ton utilisateur réel — tout s'installe dans `/home/tonuser/` même lancé avec `sudo`.

---

## 📂 Structure

```
toolkit/
├── install.sh                  # Script principal (menu interactif)
├── setup/
│   ├── apt-tools.sh            # Outils via apt (~800 Mo)
│   ├── git-tools.sh            # Outils via GitHub → ~/tools/
│   ├── wordlists.sh            # Wordlists → ~/wordlists/
│   └── configs.sh              # Dotfiles + ~/.zshenv
├── configs/
│   ├── .zshrc                  # Aliases, fonctions, prompt custom
│   └── tmux.conf               # Config tmux
├── scripts/
│   ├── revshell.sh             # Générateur de reverse shells (CLI)
│   ├── recon/                  # Scripts de recon perso
│   ├── web/                    # Scripts web perso
│   └── utils/                  # Utilitaires divers
└── wordlists/
    └── README.md               # Références wordlists
```

> 🔒 La version Pro ajoute `setup/re-tools.sh`, `iot-tools.sh`, `cloud-mobile-tools.sh`, `ad-tools.sh`, `api-tools.sh` et un fichier d'alias dédié.

> ⚠️ `~/tools/` et `~/wordlists/` sont créés sur ta machine — ils ne sont pas dans ce repo.

---

## 🛠️ Ce qui est installé

### Via apt

| Catégorie | Outils |
|---|---|
| Recon & OSINT | nmap, amass, recon-ng, maltego, sherlock, dnsenum, whatweb, exiftool, whois, dnsutils (dig/nslookup/host) |
| Web | burpsuite, zaproxy, ffuf, gobuster, feroxbuster, nikto, curl, dirb, wfuzz, sqlmap, wafw00f, xsser, clamav |
| Réseau & Énumération | netcat, hydra, enum4linux, nbtscan, onesixtyone, snmp (snmpwalk/snmp-check), macchanger, wireshark, tcpdump, socat, arp-scan, smbmap, smbclient, samba-common-bin (rpcclient), rpcbind (rpcinfo), nfs-common (showmount), ident-user-enum, cewl, wpscan, fierce, tnscmd10g, ldap-utils, hash-identifier |
| Bases de données | mysql-client, postgresql-client |
| Passwords | hashcat, john, crunch, medusa, ncrack |
| RE (base) | gdb, binutils (readelf, objdump, strings, file), strace, ltrace, binwalk, upx, radare2 |
| Exploit | metasploit-framework |
| Utils | tmux, git, jq, wget, unzip, golang-go, pipx, ruby, gem |

### Via GitHub → `~/tools/`

| Catégorie | Outil | Repo |
|---|---|---|
| Recon & OSINT | Spiderfoot | https://github.com/smicallef/spiderfoot |
| Recon & OSINT | Datasploit | https://github.com/DataSploit/datasploit |
| Recon & OSINT | Photon | https://github.com/s0md3v/Photon |
| Recon & OSINT | Social-Analyzer | https://github.com/qeeqbox/social-analyzer |
| OSINT | Holehe (pipx) | https://github.com/megadose/holehe |
| OSINT | TruffleHog | https://github.com/trufflesecurity/trufflehog |
| OSINT | PhoneInfoga (go) | https://github.com/sundowndev/phoneinfoga |
| OSINT | WaybackURLs (go) | https://github.com/tomnomnom/waybackurls |
| Web | XSStrike | https://github.com/s0md3v/XSStrike |
| Web | BruteXSS | https://github.com/rajeshmajumdar/BruteXSS |
| Web | Gopherus | https://github.com/tarunkant/Gopherus |
| Web | Drupwn | https://github.com/immunIT/drupwn |
| Web | Droopescan | https://github.com/SamJoan/droopescan |
| Réseau | Impacket (pipx) | https://github.com/fortra/impacket |
| Réseau | SMTP-User-Enum | https://github.com/cytopia/smtp-user-enum |
| Réseau | SIPVicious | https://github.com/EnableSecurity/sipvicious |
| Post-Exploit | PEASS-ng (LinPEAS/WinPEAS) | https://github.com/peass-ng/PEASS-ng |
| Post-Exploit | pwncat (pipx) | https://github.com/calebstewart/pwncat |
| Post-Exploit | Evil-WinRM | https://github.com/Hackplayers/evil-winrm |
| Post-Exploit | Mimikatz | https://github.com/gentilkiwi/mimikatz |
| Post-Exploit | CrackMapExec (pipx) | https://github.com/byt3bl33d3r/CrackMapExec |
| Post-Exploit | Bashfuscator | https://github.com/Bashfuscator/Bashfuscator |
| PrivEsc Windows | GodPotato | https://github.com/BeichenDream/GodPotato |
| PrivEsc Windows | PrintSpoofer | https://github.com/itm4n/PrintSpoofer |
| PrivEsc Windows | JuicyPotato | https://github.com/ohpe/juicy-potato |
| Pivoting | Chisel (go) | https://github.com/jpillora/chisel |
| Pivoting | Ligolo-ng (go) | https://github.com/nicocha30/ligolo-ng |
| Pivoting | Proxychains-ng | https://github.com/rofl0r/proxychains-ng |
| Pivoting | sshuttle (pipx) | https://github.com/sshuttle/sshuttle |
| RE | pwndbg | https://github.com/pwndbg/pwndbg |
| Reverse Shells | revshells | https://github.com/0dayCTF/reverse-shell-generator |
| Forensics | Autopsy | https://github.com/sleuthkit/autopsy |
| Forensics | Volatility3 | https://github.com/volatilityfoundation/volatility3 |
| Forensics | Plaso (pipx) | https://github.com/log2timeline/plaso |
| Recon & OSINT | theHarvester | https://github.com/laramies/theHarvester |
| OSINT | CUPP | https://github.com/Mebus/cupp |
| OSINT | Username Anarchy | https://github.com/urbanadventurer/username-anarchy |
| OSINT | h8mail (pipx) | https://github.com/khast3x/h8mail |
| Web | Dirsearch | https://github.com/maurosoria/dirsearch |
| Web | GraphQL-COP | https://github.com/dolevf/graphql-cop |
| Web | graphw00f | https://github.com/dolevf/graphw00f |
| Web | InQL (pipx) | https://github.com/doyensec/inql |
| Réseau | PureDNS (go) | https://github.com/d3mondev/puredns |
| Pivoting | Legba (go) | https://github.com/evilsocket/legba |
| RE | Detect-It-Easy (snap) | https://github.com/horsicq/Detect-It-Easy |
| Wordlists | Wister | https://github.com/cycurity/wister |
| Wordlists | kwprocessor | https://github.com/hashcat/kwprocessor |
| Automatisation/IA | Ollama | https://ollama.ai |
| Automatisation/IA | CAI | https://github.com/aliasrobotics/cai |

### 🔒 Modules avancés (Pro)

Les menus "par catégorie" [12] Active Directory et [13] API & GraphQL de `install.sh` restent disponibles en lite (installation à la carte des outils ci-dessus, un par un). Les modules **Reverse Engineering**, **IoT & WiFi** et **Cloud & Mobile**, ainsi que l'installation groupée AD / API & GraphQL, sont réservés à la version [Pro](#-toolkit-pro) — voir son propre README pour le détail des outils.

---

## ⚙️ Environnement configuré

`configs.sh` configure 3 fichiers :

| Fichier | Rôle |
|---|---|
| `~/.zshrc` → lien vers `configs/.zshrc` | Aliases, fonctions, prompt |
| `~/.tmux.conf` → lien vers `configs/tmux.conf` | Config tmux |
| `~/.zshenv` | Exports `$TOOLS`, `$WORDLISTS`, `$PATH` |

> Prompt différencié : `[kali@kali]` pour user normal, `[ROOT@kali]` en rouge pour root.

---

## ⚡ Aliases disponibles

### Recon
```
nmap-quick <ip>       # nmap -sV -sC -T4
nmap-full <ip>        # nmap -sV -sC -p-
nmap-udp <ip>         # nmap -sU -T4
nmap-vuln <ip>        # nmap --script vuln
nmap-save <ip>        # nmap -sV -sC -T4 -oA scan
```

### Web
```
ffuf-dir              # ffuf directories (medium wordlist)
ffuf-sub              # ffuf sous-domaines
gobuster-dir          # gobuster dir
sqlmap                # sqlmap --batch
xsstrike              # python3 xsstrike/xsstrike.py
gopherus              # python3 gopherus/gopherus.py
```

### OSINT
```
spiderfoot            # OSINT → http://127.0.0.1:5001
holehe <email>        # Vérifie l'email sur 120+ services
phoneinfroga -n +33…  # OSINT numéro de téléphone
waybackurls <domain>  # URLs archivées Wayback Machine
photon                # python3 photon/photon.py
datasploit            # python3 datasploit/datasploit.py
```

### Post-Exploitation
```
secretsdump <args>    # Impacket secretsdump
GetNPUsers <args>     # AS-REP Roasting
GetUserSPNs <args>    # Kerberoasting
linpeas               # LinPEAS local .sh
winpeas               # WinPeas local .exe
evil-winrm -i <ip>    # WinRM shell
cme smb <ip>          # CrackMapExec SMB
```

### PrivEsc Windows
```
godpotato             # Token Impersonation (Win 2012→2022)
printspoofer          # Token Impersonation (Win10/2019)
juicypotato           # Token Impersonation (legacy)
```

### Pivoting
```
chisel-server         # Chisel serveur (attaquant)
ligolo-proxy          # Ligolo-ng proxy (attaquant)
```

> 🔒 Aliases Reverse Engineering et IoT & WiFi : voir toolkit Pro.

### Utils
```
serve                 # python3 -m http.server 8080
serve-linpeas         # Sert linpeas + affiche commande cible
serve-tool <path>     # Sert n'importe quel fichier via HTTP
listen <port>         # nc -lvnp <port>
target <nom>          # Crée workspace/{recon,web,exploit,loot,notes,re}
quickscan <ip>        # Scan nmap + sauvegarde automatique
b64e / b64d           # Encode / décode base64
urlencode <string>    # URL encode
myip                  # IP publique
localip               # IP locale
```

---

## 🐚 Reverse shells

```bash
./scripts/revshell.sh <LHOST> <LPORT> all
# Types : bash · python · php · netcat · perl · ruby · powershell · upgrade · all
```

---

## 📦 Wordlists

Structure finale dans `~/wordlists/` :

```
passwords/rockyou.txt
directories/common.txt · medium.txt · big.txt
subdomains/top5000.txt · top20000.txt
usernames/common.txt · names.txt
fuzzing/fuzz.txt · lfi.txt
seclists/              ← SecLists complet
```

---

## ⚠️ Étapes post-installation

| Outil | Commande requise |
|---|---|
| pwndbg | `cd ~/tools/pwndbg && ./setup.sh` |
| Bashfuscator | `cd ~/tools/bashfuscator && pipx install .` |
| Evil-WinRM | `gem install evil-winrm` |
| Chisel | `cd ~/tools/chisel && go build .` |
| Ligolo-ng | `cd ~/tools/ligolo-ng/cmd/proxy && go build .` |
| Proxychains-ng | `cd ~/tools/proxychains-ng && ./configure && make && make install` |

> Tous les outils Python (pwntools, pwncat, crackmapexec, holehe, sshuttle, plaso...) sont installés automatiquement via **pipx** — aucune étape manuelle requise.

---

## ➕ Ajouter un outil

### Via apt
Ouvrir `setup/apt-tools.sh` et ajouter dans la bonne catégorie :
```bash
install_apt nom-outil
```

### Via GitHub
Ouvrir `setup/git-tools.sh` et ajouter :
```bash
clone_tool "nom-outil" "https://github.com/user/repo"
```
Puis ajouter l'alias dans `configs/.zshrc`.

---

## 🔄 Mettre à jour le toolkit

```bash
cd ~/toolkit
git pull
source ~/.zshrc
```

Pour réinstaller un module :
```bash
sudo bash setup/apt-tools.sh          # outils apt
sudo bash setup/git-tools.sh          # outils GitHub
sudo bash setup/wordlists.sh          # wordlists
sudo bash setup/configs.sh            # configs (.zshrc, tmux)
```

> 🔒 Modules Pro : voir le README du toolkit Pro.

---

## 📝 Outils sans installation automatisée (Notion → non applicables ici)

Certains outils de la Tools List Notion n'ont pas d'équivalent Linux installable par script — soit parce qu'ils sont Windows/macOS uniquement, soit parce qu'ils sont des services web/API sans CLI, soit parce qu'ils sont hébergés par la cible elle-même :

| Outil | Pourquoi |
|---|---|
| Active Directory | Rôle natif Windows Server, pas un outil attaquant |
| Rubeus | Windows/.NET — compiler avec Visual Studio |
| X64dbg, IDA, Eric Zimmerman's Tools, Magnet AXIOM, FTK Imager, DumpIt | Windows uniquement (GUI ou binaires .exe) |
| Shodan / Censys | Service web/API — nécessite une clé API, pas de paquet local |
| Wappalyzer | Extension de navigateur |
| Corellium, Genymotion | Service cloud payant / GUI à télécharger manuellement |
| class-dump | macOS uniquement (`brew install class-dump`) |
| Voyager, GraphiQL, Swagger UI | Interfaces hébergées par la cible (ou démo en ligne) |
| Metagoofil / FOCA | FOCA est Windows uniquement ; Metagoofil (Python 2, abandonné) à cloner manuellement si besoin |

---

## ⚠️ Disclaimer

Usage **éducatif et légal uniquement**.
