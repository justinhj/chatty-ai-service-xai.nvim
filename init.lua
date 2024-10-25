local chatty = require('chatty-ai')

---@class CompletionServiceConfig
---@field public name string
---@field public stream_error_cb function
---@field public stream_complete_cb function
---@field public error_cb function
---@field public complete_cb function
---@field public stream_cb function
---@field public configure_call function

-- > curl http://localhost:11434/api/chat -d '{
--   "model": "qwen2.5:3b", "stream": false,
--   "messages": [
--     {
--       "role": "user",
--       "content": "what are some popular declarative programming languages? Please limit to 5"
--     }
--   ]
-- }'

---@class OllamaConfig
---@field scheme string?
---@field host string?
---@field port number?
---@field model string?

---@type OllamaConfig
local default_config = {
  scheme = 'http',
  host = 'localhost',
  port = 11434,
  model = 'qwen2.5:3b',
}

local config = default_config

local CHAT_PATH = '/api/chat'

local source = {}

source.new = function()
  local self = setmetatable({}, { __index = source })
  return self
end

source.setup = function(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", {}, default_config, opts)
end

-- TODO config must be per config instance
source.get_config = function()
  return config
end

-- return url, headers, body
source.configure_call = function(user_prompt, completion_config, is_stream)
  local url = config.scheme .. '://' .. config.host .. ':' .. config.port .. CHAT_PATH
  local headers = {sample = 'pretend value'}
  local body = {
    model = config.model,
    stream = false,
    messages = {
      { role = 'user',
        content = 'Briefly, what do liberals believe about taxation?',
      },
    }
  }
  return url, headers, body
end

source.complete_cb = function(out)
  -- parse the response, handle errors, return the text, token usage
  local response = vim.fn.json_decode(out.body)
  local input_tokens = response.prompt_eval_count
  local output_tokens = response.eval_count
  local content = response.message.content

  return {
    content = content,
    input_tokens = input_tokens,
    output_tokens = output_tokens,
  }
end

chatty.register_service('ollama', source.new())

return {
  setup = source.setup,
  get_config = function()
    return config
  end
}
