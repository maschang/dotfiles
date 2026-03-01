#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

link_file() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/"
    echo "  backed up $dst → $BACKUP_DIR/"
  fi
  ln -s "$src" "$dst"
  echo "  $dst → $src"
}

# home/ → ~/ (claude/ はディレクトリごとリンクせず中身を個別リンク)
echo "Linking home/ files..."
for file in "$DOTFILES_DIR"/home/*; do
  name="$(basename "$file")"
  if [ "$name" = "claude" ]; then
    continue
  fi
  link_file "$file" "$HOME/.$name"
done

# home/claude/ → ~/.claude/ (通常ファイルだけ個別リンク、ディレクトリはスキップ)
echo "Linking Claude Code settings..."
mkdir -p "$HOME/.claude"
for file in "$DOTFILES_DIR"/home/claude/*; do
  [ -f "$file" ] || continue
  name="$(basename "$file")"
  link_file "$file" "$HOME/.claude/$name"
done

# config/wezterm/ → ~/.config/wezterm/
echo "Linking WezTerm settings..."
mkdir -p "$HOME/.config/wezterm"
for file in "$DOTFILES_DIR"/config/wezterm/*; do
  [ -e "$file" ] || continue
  name="$(basename "$file")"
  link_file "$file" "$HOME/.config/wezterm/$name"
done

# config/starship/ → ~/.config/
echo "Linking Starship settings..."
mkdir -p "$HOME/.config"
link_file "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"

# config/nvim/ → ~/.config/nvim/ (ディレクトリごとリンク)
echo "Linking Neovim settings..."
link_file "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

# config/cursor/ → ~/Library/Application Support/Cursor/User/
CURSOR_DIR="$HOME/Library/Application Support/Cursor/User"
if [ -d "$CURSOR_DIR" ] || [ -d "$(dirname "$CURSOR_DIR")" ]; then
  echo "Linking Cursor settings..."
  mkdir -p "$CURSOR_DIR"
  for file in "$DOTFILES_DIR"/config/cursor/*; do
    [ -e "$file" ] || continue
    name="$(basename "$file")"
    link_file "$file" "$CURSOR_DIR/$name"
  done
fi

echo "Done!"
