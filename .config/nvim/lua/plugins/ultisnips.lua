return {
  'SirVer/ultisnips',
  event = 'InsertEnter',
  config = function()
    vim.g.UltiSnipsExpandTrigger = '<Tab>'
    vim.g.UltiSnipsJumpForwardTrigger = '<Tab>'
    vim.g.UltiSnipsJumpBackwardTrigger = '<S-Tab>'
    vim.g.UltiSnipsSnippetDirectories = { vim.env.HOME .. '/.config/nvim/UltiSnips' }
  end,
}
