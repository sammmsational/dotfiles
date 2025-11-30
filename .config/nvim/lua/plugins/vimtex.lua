return {
  'lervag/vimtex',
  lazy = false,
  ft = { 'tex' },
  init = function() -- vimtex options, loaded before plugin
    -- Skim sync settings:
    -- Command: /opt/homebrew/bin/nvim
    -- Arguments: --headless -c "VimtexInverseSearch %line '%file'"
    vim.g.vimtex_view_method = 'skim'
    vim.g.vimtex_imaps_enabled = 0
    vim.opt.conceallevel = 2
  end,
  config = function() -- vimtex keybinds, loaded after plugin
    vim.cmd [[
    function! s:TexFocusVim() abort
      silent execute "!open -a iTerm"
      redraw!
    endfunction
    augroup vimtex_event_focus
      au!
      au User VimtexEventViewReverse call s:TexFocusVim()
    augroup END
    ]]
  end,
}
