#!/usr/bin/env bash
#
# setup-ubuntu.sh
# Script de configuração pessoal do Ubuntu
# Estética: GNOME + tema vermelho minimalista + kitty + oh-my-posh
#
# Uso:
#   chmod +x setup-ubuntu.sh
#   ./setup-ubuntu.sh [--minimal|--full] [--help]
#
# Flags:
#   --minimal   Instala só o essencial (shell, terminal, fontes, prompt)
#   --full      Instala tudo, incluindo apps do dia a dia (padrão)
#   --help      Mostra esta mensagem
#
set -euo pipefail

# ============================================================
# Configuração
# ============================================================
MODE="full"
POSH_THEME_DIR="$HOME/.poshthemes"
FONT_DIR="$HOME/.local/share/fonts"

# ============================================================
# Helpers de log
# ============================================================
info()  { echo -e "\e[31m[*]\e[0m $1"; }   # vermelho, combinando com o tema
ok()    { echo -e "\e[32m[OK]\e[0m $1"; }
warn()  { echo -e "\e[33m[!]\e[0m $1"; }
err()   { echo -e "\e[31m[ERRO]\e[0m $1" >&2; }

command_exists() { command -v "$1" &>/dev/null; }

# ============================================================
# Parse de argumentos
# ============================================================
print_help() {
  cat <<EOF
Uso: ./setup-ubuntu.sh [OPÇÃO]

  --minimal   Instala só o essencial (shell, terminal, fontes, prompt)
  --full      Instala tudo, incluindo apps do dia a dia (padrão)
  --help      Mostra esta mensagem
EOF
}

for arg in "$@"; do
  case "$arg" in
    --minimal) MODE="minimal" ;;
    --full)    MODE="full" ;;
    --help|-h) print_help; exit 0 ;;
    *) err "Opção desconhecida: $arg"; print_help; exit 1 ;;
  esac
done

if [[ $EUID -eq 0 ]]; then
  warn "Não rode este script como root. Ele vai usar sudo quando precisar."
  exit 1
fi

# ============================================================
# Funções principais
# ============================================================

update_system() {
  info "Atualizando o sistema..."
  sudo apt update && sudo apt full-upgrade -y
  ok "Sistema atualizado."
}

enable_repos() {
  info "Habilitando repositórios universe e multiverse..."
  sudo add-apt-repository -y universe
  sudo add-apt-repository -y multiverse
  sudo apt update
  ok "Repositórios habilitados."
}

install_base_packages() {
  info "Instalando pacotes básicos..."
  local packages=(
    build-essential curl wget git unzip
    gnome-tweaks gnome-shell-extension-manager gnome-shell-extensions
    flatpak gnome-software-plugin-flatpak
    kitty fastfetch fonts-firacode
  )
  sudo apt install -y "${packages[@]}"

  if ! flatpak remote-list | grep -q flathub; then
    info "Adicionando repositório Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi
  ok "Pacotes básicos instalados."
}

install_nerd_font() {
  info "Instalando Nerd Font (JetBrainsMono)..."
  mkdir -p "$FONT_DIR"
  if [[ -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]]; then
    ok "Nerd Font já estava instalada."
    return
  fi
  local tmp_zip
  tmp_zip=$(mktemp)
  curl -sL -o "$tmp_zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -oq "$tmp_zip" -d "$FONT_DIR"
  rm -f "$tmp_zip"
  fc-cache -fv "$FONT_DIR" >/dev/null
  ok "Nerd Font instalada."
}

install_oh_my_posh() {
  info "Instalando oh-my-posh..."
  if command_exists oh-my-posh; then
    ok "oh-my-posh já estava instalado."
  else
    curl -s https://ohmyposh.dev/install.sh | bash -s
    if ! grep -q 'PATH=$PATH:$HOME/.local/bin' "$HOME/.bashrc" 2>/dev/null; then
      echo 'export PATH=$PATH:$HOME/.local/bin' >> "$HOME/.bashrc"
    fi
    ok "oh-my-posh instalado."
  fi

  mkdir -p "$POSH_THEME_DIR"
  if [[ ! -f "$POSH_THEME_DIR/atomic.omp.json" ]]; then
    curl -sL -o "$POSH_THEME_DIR/atomic.omp.json" \
      "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/atomic.omp.json"
  fi

  if ! grep -q "oh-my-posh init bash" "$HOME/.bashrc" 2>/dev/null; then
    echo "eval \"\$(oh-my-posh init bash --config $POSH_THEME_DIR/atomic.omp.json)\"" >> "$HOME/.bashrc"
  fi
  ok "oh-my-posh configurado com o tema atomic."
}

install_extra_apps() {
  info "Instalando apps do dia a dia via Flatpak..."
  local apps=(
    "com.visualstudio.code"
    "com.discordapp.Discord"
    "com.spotify.Client"
    "org.telegram.desktop"
    "com.obsproject.Studio"
  )
  for app in "${apps[@]}"; do
    if flatpak list | grep -q "$app"; then
      ok "$app já instalado."
    else
      info "Instalando $app..."
      flatpak install -y flathub "$app"
    fi
  done
  ok "Apps extras instalados."
}

print_summary() {
  echo
  ok "Setup concluído! (modo: $MODE)"
  echo "Próximos passos manuais:"
  echo "  1. Reinicie o terminal (ou rode: source ~/.bashrc)"
  echo "  2. Copie kitty.conf para ~/.config/kitty/kitty.conf"
  echo "  3. Copie config.jsonc para ~/.config/fastfetch/config.jsonc"
  echo "  4. Abra o GNOME Tweaks/Extension Manager para o visual minimalista"
  echo "  5. Rode 'fastfetch' para conferir o resultado"
}

# ============================================================
# Execução
# ============================================================
main() {
  update_system
  enable_repos
  install_base_packages
  install_nerd_font
  install_oh_my_posh

  if [[ "$MODE" == "full" ]]; then
    install_extra_apps
  fi

  print_summary
}

main
