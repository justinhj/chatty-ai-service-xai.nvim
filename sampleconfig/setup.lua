-- setup chatty and the ollama config
local chatty = require('chatty-ai')
local ollama = require('init')

---@type OllamaConfig
local ollama_config = {
  model = 'qwen2.5:3b'
}

ollama.setup(ollama_config)
-- vim.print(ollama.get_config())

local chatty_config = {
  services = {
    'ollama'
  },
}

chatty.setup(chatty_config)

-- local ollama_config2 = {
--   host = '192.168.0.2'
-- }

-- ollama.setup(ollama_config2)
-- vim.print(ollama.get_config())

vim.api.nvim_set_keymap('n', '<leader>ac', [[<cmd>lua require('chatty-ai').complete("ollama", "filetype_input", 'code_writer', 'buffer_replace', false)<CR>]], {noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>as', [[<cmd>lua require('chatty-ai').complete("ollama", "filetype_input", 'code_writer', 'buffer_replace', true)<CR>]], {noremap = true, silent = true })
