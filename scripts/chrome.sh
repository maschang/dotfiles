#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLONE_DIR="$HOME/.chrome-extensions"
EXTERNAL_EXT_DIR="$HOME/Library/Application Support/Google/Chrome/External Extensions"

# --- Unpacked extensions (from GitHub) ---
install_unpacked() {
  local txt="$DOTFILES_DIR/config/chrome/extensions.txt"
  [ -f "$txt" ] || return 0

  mkdir -p "$CLONE_DIR"

  while IFS= read -r url || [ -n "$url" ]; do
    # skip blank lines and comments
    [[ -z "$url" || "$url" =~ ^# ]] && continue

    local repo_name
    repo_name="$(basename "$url" .git)"
    local dest="$CLONE_DIR/$repo_name"

    if [ -d "$dest/.git" ]; then
      echo "  pulling $repo_name ..."
      git -C "$dest" pull --ff-only
    else
      echo "  cloning $repo_name ..."
      git clone "$url" "$dest"
    fi
  done < "$txt"

  if [ -d "$CLONE_DIR" ] && [ "$(ls -A "$CLONE_DIR" 2>/dev/null)" ]; then
    echo ""
    echo "Unpacked extensions are in: $CLONE_DIR"
    echo "Load them in chrome://extensions (Developer mode → Load unpacked)"
  fi
}

# --- Web Store extensions (External Extensions) ---
install_webstore() {
  local json="$DOTFILES_DIR/config/chrome/extensions.json"
  [ -f "$json" ] || return 0

  # skip if empty object
  local keys
  keys="$(python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d))" < "$json")"
  [ "$keys" -gt 0 ] || return 0

  mkdir -p "$EXTERNAL_EXT_DIR"

  python3 -c "
import json, sys, os

src = json.load(open('$json'))
dest_dir = '$EXTERNAL_EXT_DIR'

for ext_id, meta in src.items():
    path = os.path.join(dest_dir, ext_id + '.json')
    with open(path, 'w') as f:
        json.dump(meta, f, indent=2)
    print(f'  placed {ext_id}.json')
"

  echo ""
  echo "Web Store extensions will be installed on next Chrome launch."
}

echo "==> Unpacked extensions (GitHub)"
install_unpacked

echo ""
echo "==> Web Store extensions (External Extensions)"
install_webstore

echo ""
echo "Done."
