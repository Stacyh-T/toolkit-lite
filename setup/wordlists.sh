#!/bin/bash

# ============================================================
#   WORDLISTS SETUP
#   Vérifie les wordlists existantes et organise via liens
#   symboliques. Télécharge uniquement ce qui manque.
# ============================================================

REAL_USER="${REAL_USER:-${SUDO_USER:-$USER}}"
REAL_HOME="${REAL_HOME:-$(getent passwd "$REAL_USER" | cut -d: -f6)}"
WORDLISTS_DIR="$REAL_HOME/wordlists"

# Emplacements Kali/Parrot par défaut
KALI_WORDLISTS="/usr/share/wordlists"
KALI_SECLISTS="/usr/share/seclists"
KALI_DIRBUSTER="/usr/share/dirbuster/wordlists"
KALI_DIRB="/usr/share/dirb/wordlists"

ok()   { echo -e "\033[0;32m[✓]\033[0m $1"; }
skip() { echo -e "\033[0;36m[~]\033[0m $1"; }
fail() { echo -e "\033[0;31m[✗]\033[0m $1"; }
step() { echo -e "\n\033[0;36m[*]\033[0m $1"; }
info() { echo -e "\033[1;33m[>]\033[0m $1"; }

safe_link() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [ -L "$dest" ]; then
    skip "$label (lien déjà présent — ignoré)"
    return
  fi
  if [ -f "$src" ]; then
    ln -sf "$src" "$dest" && ok "$label → $src"
  else
    fail "$label — source introuvable : $src"
  fi
}

mkdir -p "$WORDLISTS_DIR"/{passwords,directories,usernames,subdomains,fuzzing}
chown -R "$REAL_USER":"$REAL_USER" "$WORDLISTS_DIR"

# ── SECLISTS ─────────────────────────────────────────────────
step "SecLists"

if [ -d "$KALI_SECLISTS" ]; then
  skip "SecLists déjà présent dans $KALI_SECLISTS (installé via apt)"
  SECLISTS_DIR="$KALI_SECLISTS"
elif [ -d "$WORDLISTS_DIR/seclists" ]; then
  skip "SecLists déjà cloné dans $WORDLISTS_DIR/seclists"
  info "Vérification des mises à jour..."
  git -C "$WORDLISTS_DIR/seclists" pull -q && ok "SecLists à jour"
  SECLISTS_DIR="$WORDLISTS_DIR/seclists"
else
  info "SecLists introuvable — clonage en cours (~1 Go)..."
  git clone --depth=1 https://github.com/danielmiessler/SecLists \
    "$WORDLISTS_DIR/seclists" \
    && ok "SecLists cloné" \
    || fail "Échec du clonage SecLists"
  chown -R "$REAL_USER":"$REAL_USER" "$WORDLISTS_DIR/seclists"
  SECLISTS_DIR="$WORDLISTS_DIR/seclists"
fi

# ── ROCKYOU ──────────────────────────────────────────────────
step "RockYou"

ROCKYOU_DEST="$WORDLISTS_DIR/passwords/rockyou.txt"

if [ -L "$ROCKYOU_DEST" ]; then
  skip "rockyou.txt (lien déjà présent — ignoré)"
elif [ -f "$KALI_WORDLISTS/rockyou.txt" ]; then
  ln -sf "$KALI_WORDLISTS/rockyou.txt" "$ROCKYOU_DEST"
  ok "rockyou.txt → lien depuis $KALI_WORDLISTS/rockyou.txt"
elif [ -f "$KALI_WORDLISTS/rockyou.txt.gz" ]; then
  info "rockyou.txt compressé trouvé — décompression..."
  gunzip -k "$KALI_WORDLISTS/rockyou.txt.gz"
  ln -sf "$KALI_WORDLISTS/rockyou.txt" "$ROCKYOU_DEST"
  ok "rockyou.txt décompressé et lié"
elif [ -f "$SECLISTS_DIR/Passwords/Leaked-Databases/rockyou.txt.tar.gz" ]; then
  info "rockyou.txt trouvé dans SecLists — extraction..."
  tar -xzf "$SECLISTS_DIR/Passwords/Leaked-Databases/rockyou.txt.tar.gz" \
    -C "$WORDLISTS_DIR/passwords/"
  ok "rockyou.txt extrait depuis SecLists"
else
  fail "rockyou.txt introuvable — téléchargement manuel requis"
  info "Commande : wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -O $ROCKYOU_DEST"
fi

# ── DIRECTORIES ──────────────────────────────────────────────
step "Wordlists Directories"

if [ -f "$SECLISTS_DIR/Discovery/Web-Content/common.txt" ]; then
  safe_link "$SECLISTS_DIR/Discovery/Web-Content/common.txt" \
    "$WORDLISTS_DIR/directories/common.txt" "directories/common.txt"
elif [ -f "$KALI_DIRB/common.txt" ]; then
  safe_link "$KALI_DIRB/common.txt" \
    "$WORDLISTS_DIR/directories/common.txt" "directories/common.txt (dirb)"
fi

if [ -f "$SECLISTS_DIR/Discovery/Web-Content/directory-list-2.3-medium.txt" ]; then
  safe_link "$SECLISTS_DIR/Discovery/Web-Content/directory-list-2.3-medium.txt" \
    "$WORDLISTS_DIR/directories/medium.txt" "directories/medium.txt"
elif [ -f "$KALI_DIRBUSTER/directory-list-2.3-medium.txt" ]; then
  safe_link "$KALI_DIRBUSTER/directory-list-2.3-medium.txt" \
    "$WORDLISTS_DIR/directories/medium.txt" "directories/medium.txt (dirbuster)"
fi

if [ -f "$SECLISTS_DIR/Discovery/Web-Content/directory-list-2.3-big.txt" ]; then
  safe_link "$SECLISTS_DIR/Discovery/Web-Content/directory-list-2.3-big.txt" \
    "$WORDLISTS_DIR/directories/big.txt" "directories/big.txt"
elif [ -f "$KALI_DIRBUSTER/directory-list-2.3-big.txt" ]; then
  safe_link "$KALI_DIRBUSTER/directory-list-2.3-big.txt" \
    "$WORDLISTS_DIR/directories/big.txt" "directories/big.txt (dirbuster)"
fi

# ── SUBDOMAINS ───────────────────────────────────────────────
step "Wordlists Subdomains"

safe_link \
  "$SECLISTS_DIR/Discovery/DNS/subdomains-top1million-5000.txt" \
  "$WORDLISTS_DIR/subdomains/top5000.txt" \
  "subdomains/top5000.txt"

safe_link \
  "$SECLISTS_DIR/Discovery/DNS/subdomains-top1million-20000.txt" \
  "$WORDLISTS_DIR/subdomains/top20000.txt" \
  "subdomains/top20000.txt"

# ── USERNAMES ────────────────────────────────────────────────
step "Wordlists Usernames"

safe_link \
  "$SECLISTS_DIR/Usernames/top-usernames-shortlist.txt" \
  "$WORDLISTS_DIR/usernames/common.txt" \
  "usernames/common.txt"

safe_link \
  "$SECLISTS_DIR/Usernames/Names/names.txt" \
  "$WORDLISTS_DIR/usernames/names.txt" \
  "usernames/names.txt"

# ── FUZZING ──────────────────────────────────────────────────
step "Wordlists Fuzzing"

safe_link \
  "$SECLISTS_DIR/Fuzzing/fuzz-Bo0oM.txt" \
  "$WORDLISTS_DIR/fuzzing/fuzz.txt" \
  "fuzzing/fuzz.txt"

safe_link \
  "$SECLISTS_DIR/Fuzzing/LFI/LFI-Jhaddix.txt" \
  "$WORDLISTS_DIR/fuzzing/lfi.txt" \
  "fuzzing/lfi.txt"

# ── RÉSUMÉ ───────────────────────────────────────────────────
echo ""
ok "Wordlists prêtes dans : $WORDLISTS_DIR"
echo ""
echo "  Structure :"
echo "    passwords/rockyou.txt"
echo "    directories/common.txt · medium.txt · big.txt"
echo "    subdomains/top5000.txt · top20000.txt"
echo "    usernames/common.txt · names.txt"
echo "    fuzzing/fuzz.txt · lfi.txt"
echo "    seclists/ → $SECLISTS_DIR"
