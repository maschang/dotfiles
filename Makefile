DOTFILES_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.DEFAULT_GOAL := help

install: brew link ## brew + link を実行

link: ## シンボリックリンクを作成
	@bash $(DOTFILES_DIR)/scripts/link.sh

brew: ## Homebrew とパッケージをインストール
	@bash $(DOTFILES_DIR)/scripts/brew.sh

iterm2: ## [手動] iTerm2 カラースキームを読み込み
	@for f in $(DOTFILES_DIR)/config/iterm2/*.itermcolors; do \
		[ -e "$$f" ] && open "$$f" && echo "  imported $$(basename $$f)"; \
	done
	@echo "iTerm2: select the color preset in Preferences > Profiles > Colors"

cursor-extensions: ## [手動] Cursor 拡張機能をインストール
	@echo "Installing Cursor extensions..."
	@while IFS= read -r ext || [ -n "$$ext" ]; do \
		[ -z "$$ext" ] && continue; \
		cursor --install-extension "$$ext" && echo "  installed $$ext"; \
	done < $(DOTFILES_DIR)/config/cursor/extensions.txt

clean-backup: ## dotfiles のバックアップを削除
	@if [ -d "$(HOME)/.dotfiles_backup" ]; then \
		rm -rf "$(HOME)/.dotfiles_backup"; \
		echo "Removed ~/.dotfiles_backup"; \
	else \
		echo "No backups found."; \
	fi

help: ## このヘルプを表示
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
