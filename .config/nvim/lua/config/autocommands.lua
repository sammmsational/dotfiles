-- ******************** BASIC AUTOCOMMANDS ********************
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('InsertEnter', {
  desc = 'Absolute line numbers when entering Insert mode',
  callback = function()
    vim.o.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  desc = 'Relative line numbers when leaving Insert mode',
  callback = function()
    vim.o.relativenumber = true
  end,
})
