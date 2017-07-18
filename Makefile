DOTFILES_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.DEFAULT_GOAL := help

install: brew link ## Run brew + link

link: ## Create symlinks
	@bash $(DOTFILES_DIR)/scripts/link.sh

brew: ## Install Homebrew and packages
	@bash $(DOTFILES_DIR)/scripts/brew.sh

iterm2: ## Import iTerm2 color schemes
	@for f in $(DOTFILES_DIR)/config/iterm2/*.itermcolors; do \
		[ -e "$$f" ] && open "$$f" && echo "  imported $$(basename $$f)"; \
	done
	@echo "iTerm2: select the color preset in Preferences > Profiles > Colors"

clean-backup: ## Remove all dotfiles backups
	@if [ -d "$(HOME)/.dotfiles_backup" ]; then \
		rm -rf "$(HOME)/.dotfiles_backup"; \
		echo "Removed ~/.dotfiles_backup"; \
	else \
		echo "No backups found."; \
	fi

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
