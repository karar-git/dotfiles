return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  build = 'make',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'stevearc/dressing.nvim',
  },
  config = function()
    require('avante').setup {
      provider = 'openai',
      openai = {
        api_key = os.getenv('OPENAI_API_KEY'),
        model = 'gpt-4.1-mini',
      },
    }
  end,
}
