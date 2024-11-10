-- setup chatty and the xai config
local chatty = require('chatty-ai')
local xai = require('../lua/chatty-ai-service-xai/init')

---@type xAIConfig
local xai_config = {
  -- change model etc
}

-- Create the services

local s1 = xai.create_service('grok', xai_config)

chatty.setup({})

chatty.register_service(s1)

-- chatty.list_services()

vim.api.nvim_set_keymap('n', '<leader>ac', [[<cmd>lua require('chatty-ai').complete('grok', "filetype_input", 'Chatty AI Default', 'code_writer', 'buffer_replace', false)<CR>]], {noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>as', [[<cmd>lua require('chatty-ai').complete('grok', "filetype_input", 'Chatty AI Default', 'code_writer', 'buffer_replace', true)<CR>]], {noremap = true, silent = true })
