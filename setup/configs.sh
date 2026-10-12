#!/bin/bash

# ============================================================
#   CONFIGS SETUP
#   Applique les dotfiles (.zshrc, tmux) au vrai utilisateur
# ============================================================

REAL_USER="${REAL_USER:-${SUDO_USER:-$USER}}"
REAL_HOME="${REAL_HOME:-$(getent passwd "$REAL_USER" | cut -d: -f6)}"
TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGS_DIR="$TOOLKIT_DIR/configs"

ok()   { echo -e "\033[0;32m[✓]\033[0m $1"; }
warn() { echo -e "\033[1;33m[!]\033[0m $1"; }
step() { echo -e "\n\033[0;36m[*]\033[0m $1"; }
info() { echo -e "\033[1;33m[>]\033[0m $1"; }

backup_and_link() {
  local src="$1"
  local dest="$2"

  if [ -f "$dest" ] && [ ! -L "$dest" ]; then
    cp "$dest" "${dest}.bak"
    warn "Backup créé : ${dest}.bak"
  fi

  ln -sf "$src" "$dest"
  chown -h "$REAL_USER":"$REAL_USER" "$dest"
  ok "$dest → $src"
}

# ── DOTFILES ─────────────────────────────────────────────────
step "Application des configs pour $REAL_USER ($REAL_HOME)"

if [ -f "$CONFIGS_DIR/.zshrc" ]; then
  backup_and_link "$CONFIGS_DIR/.zshrc" "$REAL_HOME/.zshrc"
fi

if [ -f "$CONFIGS_DIR/.bashrc" ]; then
  backup_and_link "$CONFIGS_DIR/.bashrc" "$REAL_HOME/.bashrc"
fi

if [ -f "$CONFIGS_DIR/tmux.conf" ]; then
  backup_and_link "$CONFIGS_DIR/tmux.conf" "$REAL_HOME/.tmux.conf"
fi

# ── ZSHENV — exports critiques chargés en premier ────────────
step "Configuration de ~/.zshenv"

ZSHENV="$REAL_HOME/.zshenv"

# Vérifie que les exports ne sont pas déjà présents
if grep -q "TOOLS=" "$ZSHENV" 2>/dev/null; then
  warn "~/.zshenv déjà configuré — ignoré"
else
  cat >> "$ZSHENV" << ENVEOF

# ── Toolkit cybersecurity ─────────────────────────────────────
export TOOLS="\$HOME/tools"
export WORDLISTS="\$HOME/wordlists"
export PATH="\$HOME/.local/bin:\$HOME/tools:\$PATH"
ENVEOF
  chown "$REAL_USER":"$REAL_USER" "$ZSHENV"
  ok "~/.zshenv configuré avec TOOLS, WORDLISTS, PATH"
fi

# ── RECHARGEMENT ─────────────────────────────────────────────
step "Rechargement du shell pour $REAL_USER"

if [ -n "$SUDO_USER" ]; then
  su - "$REAL_USER" -c "source $REAL_HOME/.zshenv 2>/dev/null; source $REAL_HOME/.zshrc 2>/dev/null" 2>/dev/null
fi

ok "Configs appliquées dans $REAL_HOME"
echo ""
echo "  Fichiers configurés :"
echo "    ~/.zshrc    → $CONFIGS_DIR/.zshrc"
echo "    ~/.tmux.conf → $CONFIGS_DIR/tmux.conf"
echo "    ~/.zshenv   → exports TOOLS, WORDLISTS, PATH"
echo ""
warn "Ouvre un nouveau terminal pour que les changements prennent effet."
