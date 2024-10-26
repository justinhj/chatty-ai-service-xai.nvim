-- setup chatty and the ollama config
local chatty = require('chatty-ai')
local ollama = require('init') -- TODO this would be the plugin name

---@type OllamaConfig
local ollama_config_qwen25_3 = {
  model = 'qwen2.5:3b'
}

---@type OllamaConfig
local ollama_config_llama32_3 = {
  model = 'llama3.2:3b'
}

-- Create the services

local s1 = ollama.create_service('ollama-qwen25', ollama_config_qwen25_3)
local s2 = ollama.create_service('ollama-llama32', ollama_config_llama32_3)

-- Make them available to chatty
-- TODO is it needed as well as register, I think likely not
-- local chatty_config = {
--   services = {
--     'ollama-qwen25',
--     'ollama-llama32',
--   },
-- }

chatty.setup({})

chatty.register_service(s1)
chatty.register_service(s2)

chatty.list_services()

vim.api.nvim_set_keymap('n', '<leader>ac1', [[<cmd>lua require('chatty-ai').complete("ollama-qwen25", "filetype_input", 'code_writer', 'buffer_replace', false)<CR>]], {noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ac2', [[<cmd>lua require('chatty-ai').complete("ollama-llama32", "filetype_input", 'code_writer', 'buffer_replace', false)<CR>]], {noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>as1', [[<cmd>lua require('chatty-ai').complete("ollama-qwen25", "filetype_input", 'code_writer', 'buffer_replace', true)<CR>]], {noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>as2', [[<cmd>lua require('chatty-ai').complete("ollama-llama32", "filetype_input", 'code_writer', 'buffer_replace', true)<CR>]], {noremap = true, silent = true })
