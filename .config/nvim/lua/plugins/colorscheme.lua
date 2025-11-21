return {
  {
    'catppuccin/nvim',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = 'macchiato',
        transparent_background = false,
      }

      -- vim.cmd.colorscheme 'catppuccin'
    end,
  },
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      require('kanagawa').setup {}

      -- vim.cmd.colorscheme 'kanagawa-lotus' -- light
      -- vim.cmd.colorscheme 'kanagawa-dragon' -- black
      -- vim.cmd.colorscheme 'kanagawa-wave' -- dark
    end,
  },
  {
    'thesimonho/kanagawa-paper.nvim',
    lazy = false,
    priority = 1000,
    opts = { transparent = false },
    init = function()
      vim.cmd.colorscheme 'kanagawa-paper-ink' -- dark
      -- vim.cmd.colorscheme 'kanagawa-paper-canvas' -- light
    end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    init = function()
      -- vim.cmd.colorscheme 'tokyonight'
    end,
  },
}
