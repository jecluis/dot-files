-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- lvim.log.level = "trace"
-- lvim.lsp.null_ls.setup.debug = true

lvim.plugins = {
  {
    "wfxr/minimap.vim",
    build = "cargo install --locked code-minimap",
    cmd = { "Minimap", "MinimapClose", "MinimapToggle", "MinimapRefresh", "MinimapUpdateHighlight" },
    config = function()
      vim.cmd("let g:minimap_width = 10")
      vim.cmd("let g:minimap_auto_start = 1")
      vim.cmd("let g:minimap_auto_start_win_enter = 1")
    end,
  },
  {
    "p00f/clangd_extensions.nvim",
    config = function()
      require("clangd_extensions").setup()
    end,
  },
  {
    "Mofiqul/vscode.nvim",
    config = function()
      local c = require("vscode.colors").get_colors()
      require("vscode").setup({
        style = "dark",
        italic_comments = true,
        color_overrides = {
          vscLineNumber = "#FFFFFF",
        },
        group_overrides = {
          Cursor = {
            fg = c.vscDarkBlue,
            bg = c.vscLightGreen,
            bold = true,
          },
        },
      })
      require("vscode").load()
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = {
          width = 30,
        },
        buffers = {
          follow_current_file = true,
        },
        filesystem = {
          follow_current_file = true,
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {},
            never_show = {},
          },
        },
      })
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      warn_no_results = false,
      open_no_results = true,
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
  },
  -- { "hrsh7th/cmp-nvim-lsp-signature-help" },
}

lvim.builtin.nvimtree.active = false -- note: using neo-tree.nvim
lvim.format_on_save.enabled = true
lvim.format_on_save.pattern = { "*.lua", "*.py", "*.md", "*.sh" }

lvim.builtin.which_key.mappings["t"] = {
  name = "Diagnostics",
  t = { "<cmd>Trouble diagnostics toggle<cr>", "trouble" },
  -- w = { "<cmd>Trouble diagnostics workspace_diagnostics<cr>", "workspace" },
  -- d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
  -- q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
  l = { "<cmd>Trouble loclist toggle<cr>", "loclist" },
  -- r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup({
  {
    name = "black",
    filetypes = { "python" },
  },
  {
    name = "isort",
    filetypes = { "python" },
  },
  {
    name = "prettierd",
    filetypes = { "markdown" },
  },
  {
    name = "shfmt",
    filetypes = { "sh", "bash" },
    args = { "--simplify", "--indent", "2" },
  }
})

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  {
    command = "markdownlint_cli2",
    filetypes = { "markdown" },
    args = { "$FILENAME" },
    -- args = { "**/*.md" },
  },
  -- {
  --   command = "shellcheck",
  --   filetypes = { "sh" },
  -- },
}


vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })

local pyright_opts = {
  single_file_support = true,
  settings = {
    pyright = {
      disableLanguageServices = false,
      disableOrganizeImports = false,
    },
    python = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "workspace", -- openFilesOnly, workspace
        typeCheckingMode = "strict",  -- off, basic, strict
        useLibraryCodeForTypes = true,
      },
    },
  },
}

require("lvim.lsp.manager").setup("pyright", pyright_opts)
