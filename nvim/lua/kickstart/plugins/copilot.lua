return {
  'github/copilot.vim',
  event = 'InsertEnter',
  config = function()
    -- Enable Copilot
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_tab_fallback = ''
    -- Map manually
    vim.keymap.set('i', '<C-l>', 'copilot#Accept("<CR>")', {
      expr = true,
      replace_keycodes = false,
      desc = 'Accept Copilot suggestion',
    })
  end,
}
