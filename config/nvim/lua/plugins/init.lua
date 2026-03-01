return {
  -- Treesitter: シンタックスハイライト・構文解析
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua", "ruby", "javascript", "typescript", "json", "yaml",
          "html", "css", "bash", "markdown", "markdown_inline", "vim", "vimdoc",
        },
      })
    end,
  },

  -- Telescope: ファジーファインダー
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>ff" },
      { "<leader>fg" },
      { "<leader>fb" },
      { "<leader>fh" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
    end,
  },

  -- LSP: 言語サーバー連携
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local bmap = function(mode, lhs, rhs)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf })
          end
          bmap("n", "gd", vim.lsp.buf.definition)
          bmap("n", "gr", vim.lsp.buf.references)
          bmap("n", "K", vim.lsp.buf.hover)
          bmap("n", "<leader>rn", vim.lsp.buf.rename)
          bmap("n", "<leader>ca", vim.lsp.buf.code_action)
        end,
      })

      -- Ruby
      vim.lsp.config("ruby_lsp", {})
      vim.lsp.enable("ruby_lsp")

      -- 他の LSP はここに追加
    end,
  },

  -- Gitsigns: Git 差分表示
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Oil: ファイルエクスプローラ（バッファ式）
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "-" } },
    config = function()
      require("oil").setup({
        view_options = {
          show_hidden = true,
        },
      })
    end,
  },
}
