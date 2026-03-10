# decaf: caffeinate をコーヒーカップのアニメーション付きで実行する関数
#
# 概要:
#   macOS の caffeinate コマンドでスリープを抑制しつつ、
#   ターミナルにコーヒーカップのアスキーアートを表示する。
#   Ctrl+C で停止。
#
# 使い方:
#   decaf
#
# 依存:
#   - caffeinate (macOS 標準)

function decaf() {
  caffeinate -d &
  local pid=$!
  trap "kill $pid 2>/dev/null; trap - INT; return" INT

  local steam1=(
    "       (  )"
    "      (    )"
    "       (  )"
    "      (    )"
  )
  local steam2=(
    "      (    )"
    "       (  )"
    "      (    )"
    "       (  )"
  )
  local cup=(
    "      .-----."
    "      |     |}"
    "      |     |}"
    "      \`-----'"
    "     \\_______/"
    "   ~~~~~~~~~~~"
  )

  local i=0
  while kill -0 $pid 2>/dev/null; do
    clear
    echo ""
    echo ""
    if (( i % 2 == 0 )); then
      for line in "${steam1[@]}"; do echo "$line"; done
    else
      for line in "${steam2[@]}"; do echo "$line"; done
    fi
    for line in "${cup[@]}"; do echo "$line"; done
    echo ""
    echo "   \033[36m~ decaf mode ~\033[0m"
    echo "   \033[2mCtrl+C to stop\033[0m"
    ((i++))
    sleep 0.8
  done
}
