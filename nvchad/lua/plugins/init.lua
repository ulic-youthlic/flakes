return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  { import = "nvchad.blink.lazyspec" },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "markdown",
        "typst",
        "lua",
        "toml",
        "yaml",
        "json",
        "rust"
      },
    },
  },
  {
    "idris-community/idris2-nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "MunifTanjim/nui.nvim"
    },
    main = "idris2",
    opts = require("configs.idris2"),
    ft = { "idris2", "ipkg", "lidris2" }
  },
  {
    "3rd/image.nvim",
    opts = {
      processor = "magick_cli",
      integrations = {
        markdown = {
          only_render_image_at_cursor = true,
          only_render_image_at_cursor_mode = "popup",
        },
      }
    },
    ft = { "markdown", "typst" }
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
  },
}
