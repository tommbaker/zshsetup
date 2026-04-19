#!/usr/bin/env bash
# This script is paired with ~/.zshrc.
# When adding a new CLI tool:
#   1. Add the package name to PACKAGES below (or install it separately in a new block)
#   2. Add a corresponding entry to the `cat <<'EOF'` aliases/tools banner in ~/.zshrc
#   3. Add any aliases for it in ~/.zshrc with inline comments
set -euo pipefail

PACKAGES=(
  eza
  bat
  git
  zsh
  ncdu
  btop
  curl
  unzip
)

# Packages that aren't available on every supported distro/release.
# Installed best-effort; missing ones do not abort the script.
#   - fastfetch: absent from Ubuntu 24.04 LTS
#   - neofetch:  removed from Debian 13 (trixie) after upstream was archived
OPTIONAL_PACKAGES=(
  fastfetch
  neofetch
)

if command -v apt >/dev/null; then
  PM_INSTALL=(sudo apt install -y)
  sudo apt update
elif command -v dnf >/dev/null; then
  PM_INSTALL=(sudo dnf install -y)
elif command -v pacman >/dev/null; then
  PM_INSTALL=(sudo pacman -S --needed --noconfirm)
elif command -v brew >/dev/null; then
  PM_INSTALL=(brew install)
else
  echo "No supported package manager found (apt/dnf/pacman/brew)." >&2
  exit 1
fi

"${PM_INSTALL[@]}" "${PACKAGES[@]}"

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
  "${PM_INSTALL[@]}" "$pkg" || echo "Optional package '$pkg' not available on this system, skipping."
done

install_nerd_font() {
  local font="JetBrainsMono"
  local version="v3.2.1"
  local dest="$HOME/.local/share/fonts/NerdFonts"

  if [[ -d "$dest" ]]; then
    echo "Nerd Fonts already installed, skipping."
    return
  fi

  mkdir -p "$dest"
  echo "Downloading $font Nerd Font $version..."
  curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${font}.zip" \
    -o /tmp/NerdFont.zip
  unzip -o /tmp/NerdFont.zip '*.ttf' -d "$dest"
  rm /tmp/NerdFont.zip
  fc-cache -fv
  echo "Nerd Font installed. Restart your terminal and set it as your terminal font."
}

install_zshrc() {
  local src dest="$HOME/.zshrc"
  src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.zshrc"

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    cp "$dest" "$dest.backup.$(date +%Y%m%d%H%M%S)"
  fi
  cp "$src" "$dest"
  echo "Installed .zshrc to $dest"
}

install_zshrc
install_nerd_font
