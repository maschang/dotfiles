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
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Help tags" },
      { "<leader>fs", "<cmd>Telescope git_status<cr>",  desc = "Git status" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
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
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 300,
          virt_text = false,
        },
        current_line_blame_formatter = "<abbrev_sha> <author>, <author_time:%Y-%m-%d> - <summary>",
      })
    end,
  },

  -- Lualine: ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons", "lewis6991/gitsigns.nvim" },
    config = function()
      local function git_blame()
        local blame = vim.b.gitsigns_blame_line_dict
        if not blame or blame.author == nil then
          return ""
        end
        if blame.author == "Not Committed Yet" then
          return "Not Committed Yet"
        end
        local hash = string.sub(blame.sha, 1, 7)
        local date = os.date("%Y-%m-%d", blame.author_time)
        return string.format("%s %s, %s - %s", hash, blame.author, date, blame.summary)
      end

      require("lualine").setup({
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { git_blame },
          lualine_y = { "filetype" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Alpha: スタートスクリーン
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- figletで生成。brew install figletで使える
      dashboard.section.header.val = {
        [[    /\_/\  /\_/\                                                    ]],
        [[   ( o.o )( -.- ) zzZ                 __                           ]],
        [[    > ^ <  > ^ <  ___      __    ___   __  __ /\_\    ___ ___      ]],
        [[                 /' _ `\  /'__`\ / __`\/\ \/\ \\/\ \ /' __` __`\  ]],
        [[                 /\ \/\ \/\  __//\ \L\ \ \ \_/ |\ \ \/\ \/\ \/\ \]],
        [[                 \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
        [[                  \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/ ]],
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",       "<cmd>Telescope find_files<cr>"),
        dashboard.button("r", "  Recent files",    "<cmd>Telescope oldfiles<cr>"),
        dashboard.button("g", "  Live grep",       "<cmd>Telescope live_grep<cr>"),
        dashboard.button("e", "  New file",        "<cmd>ene<cr>"),
        dashboard.button("q", "  Quit",            "<cmd>qa<cr>"),
      }

      alpha.setup(dashboard.opts)
    end,
  },

  -- Oil: ファイルエクスプローラ（バッファ式）
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "-", "<CMD>Oil<CR>", desc = "Open file explorer" } },
    config = function()
      require("oil").setup({
        view_options = {
          show_hidden = true,
        },
      })
    end,
  },
}
