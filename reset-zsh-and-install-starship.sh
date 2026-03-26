#!/usr/bin/env bash
set -euo pipefail

# Reset user-level Zsh config on Linux and install Starship.
# - Backs up current user config by default.
# - Removes common Zsh frameworks/config files (Oh My Zsh, Zim, dotfiles, caches).
# - Writes a minimal ~/.zshrc (or $ZDOTDIR/.zshrc) with compinit, sane history, and Starship.
# - Installs Starship to ~/.local/bin using the official installer.
#
# Usage:
#   bash reset-zsh-and-install-starship.sh
#   bash reset-zsh-and-install-starship.sh --purge-history
#   bash reset-zsh-and-install-starship.sh --no-backup

PURGE_HISTORY=0
NO_BACKUP=0
ASSUME_YES=0

for arg in "$@"; do
  case "$arg" in
    --purge-history) PURGE_HISTORY=1 ;;
    --no-backup)     NO_BACKUP=1 ;;
    -y|--yes)        ASSUME_YES=1 ;;
    -h|--help)
      sed -n '2,18p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

if [[ "${OSTYPE:-}" != linux* ]]; then
  echo "This script is intended for Linux only." >&2
  exit 1
fi

if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh is not installed. Install zsh first, then rerun this script." >&2
  exit 1
fi

TARGET_DOTDIR="${ZDOTDIR:-$HOME}"
BACKUP_ROOT="$HOME/.local/share/zsh-reset-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
STARSHIP_BIN_DIR="$HOME/.local/bin"
STARSHIP_INSTALL_URL="https://starship.rs/install.sh"
STARSHIP_CONFIG_DIR="$HOME/.config"
STARSHIP_CONFIG_FILE="$STARSHIP_CONFIG_DIR/starship.toml"

FILES_TO_REMOVE=(
  "$TARGET_DOTDIR/.zshenv"
  "$TARGET_DOTDIR/.zprofile"
  "$TARGET_DOTDIR/.zshrc"
  "$TARGET_DOTDIR/.zlogin"
  "$TARGET_DOTDIR/.zlogout"
  "$HOME/.zimrc"
  "$HOME/.p10k.zsh"
  "$HOME/.zcompdump"
  "$HOME/.config/starship.toml"
  "$STARSHIP_CONFIG_FILE"
)

DIRS_TO_REMOVE=(
  "$HOME/.oh-my-zsh"
  "$HOME/.zim"
)

GLOBS_TO_REMOVE=(
  "$HOME/.zcompdump*"
  "$TARGET_DOTDIR/.zcompdump*"
  "$HOME/.zcompcache*"
  "$TARGET_DOTDIR/.zcompcache*"
)

if [[ $PURGE_HISTORY -eq 1 ]]; then
  FILES_TO_REMOVE+=("$HOME/.zsh_history")
fi

confirm() {
  if [[ $ASSUME_YES -eq 1 ]]; then
    return 0
  fi

  echo "This will reset your user-level Zsh config and install Starship."
  echo "Target ZDOTDIR: $TARGET_DOTDIR"
  if [[ $PURGE_HISTORY -eq 1 ]]; then
    echo "History file will also be removed."
  else
    echo "History file will be preserved."
  fi
  if [[ $NO_BACKUP -eq 1 ]]; then
    echo "Backup: disabled"
  else
    echo "Backup dir: $BACKUP_DIR"
  fi
  printf 'Continue? [y/N] ' >/dev/tty
  read -r reply </dev/tty
  [[ "$reply" =~ ^[Yy]$ ]]
}

backup_path() {
  local path="$1"
  [[ -e "$path" || -L "$path" ]] || return 0

  local rel
  rel="${path#/}"
  mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  mv "$path" "$BACKUP_DIR/$rel"
}

remove_glob_matches() {
  local pattern="$1"
  shopt -s nullglob dotglob
  local matches=( $pattern )
  shopt -u dotglob
  if (( ${#matches[@]} > 0 )); then
    for m in "${matches[@]}"; do
      if [[ $NO_BACKUP -eq 1 ]]; then
        rm -rf -- "$m"
      else
        backup_path "$m"
      fi
    done
  fi
  shopt -u nullglob
}

write_minimal_zshrc() {
  mkdir -p "$TARGET_DOTDIR"
  cat > "$TARGET_DOTDIR/.zshrc" <<'ZSHRC'
autoload -Uz compinit
compinit

HISTFILE=$HOME/.zsh_history
HISTSIZE=500
SAVEHIST=500

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME

export PATH="$HOME/.local/bin:$PATH"
eval "$(starship init zsh)"
ZSHRC
}

install_starship() {
  mkdir -p "$STARSHIP_BIN_DIR"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$STARSHIP_INSTALL_URL" | sh -s -- -y -b "$STARSHIP_BIN_DIR"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$STARSHIP_INSTALL_URL" | sh -s -- -y -b "$STARSHIP_BIN_DIR"
  else
    echo "Neither curl nor wget is available. Install one of them first." >&2
    exit 1
  fi
}

apply_starship_preset() {
  mkdir -p "$STARSHIP_CONFIG_DIR"
  "$STARSHIP_BIN_DIR/starship" preset gruvbox-rainbow -o "$STARSHIP_CONFIG_FILE"
}

main() {
  if ! confirm; then
    echo "Aborted."
    exit 1
  fi

  if [[ $NO_BACKUP -eq 0 ]]; then
    mkdir -p "$BACKUP_DIR"
  fi

  for path in "${FILES_TO_REMOVE[@]}"; do
    if [[ -e "$path" || -L "$path" ]]; then
      if [[ $NO_BACKUP -eq 1 ]]; then
        rm -rf -- "$path"
      else
        backup_path "$path"
      fi
    fi
  done

  for path in "${DIRS_TO_REMOVE[@]}"; do
    if [[ -e "$path" || -L "$path" ]]; then
      if [[ $NO_BACKUP -eq 1 ]]; then
        rm -rf -- "$path"
      else
        backup_path "$path"
      fi
    fi
  done

  for pattern in "${GLOBS_TO_REMOVE[@]}"; do
    remove_glob_matches "$pattern"
  done

  write_minimal_zshrc
  install_starship
  apply_starship_preset

  cat <<EOF2

Done.

What changed:
- Removed user-level Zsh frameworks/configs (Oh My Zsh, Zim, startup dotfiles, zcompdump caches).
- Wrote a minimal Zsh config to: $TARGET_DOTDIR/.zshrc
- Installed Starship to: $STARSHIP_BIN_DIR/starship

Next steps:
1. Start a new Zsh session: exec zsh
2. Optional: make Zsh your login shell: chsh -s "$(command -v zsh)"
3. Optional: restore anything from backup: $BACKUP_DIR

EOF2
}

main
