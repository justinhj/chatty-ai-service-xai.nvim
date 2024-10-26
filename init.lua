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

local CHAT_PATH = '/api/chat'

local source = {}

source.create_service = function(name, config)
  local self = setmetatable({}, { __index = source })
  config = config or {}
  local merged_config = vim.tbl_deep_extend("force", {}, default_config, config)
  self.config = merged_config
  self.name = name
  return self
end

-- return url, headers, body
source.configure_call = function(self, user_prompt, completion_config, is_stream)
  local config = self.config
  local url = config.scheme .. '://' .. config.host .. ':' .. config.port .. CHAT_PATH
  local headers = {}
  local body = {
    model = config.model,
    stream = is_stream,
    messages = {
      { role = 'user',
        content = user_prompt,
      },
    }
  }
  return url, headers, body
end

source.complete_cb = function(response)
  local parsed_response = vim.fn.json_decode(response.body)
  local input_tokens = parsed_response.prompt_eval_count
  local output_tokens = parsed_response.eval_count
  local content = parsed_response.message.content

  return {
    content = content,
    input_tokens = input_tokens,
    output_tokens = output_tokens,
  }
end

source.stream_cb = function(chunk)
  local status, data = pcall(vim.json.decode, chunk)
  if status then
    local content = ''
    if data.message and data.message.content then
      content = data.message.content
    end
    return content
  else
    error(data)
  end
end

source.stream_complete_cb = function(response)
  local body = response.body
  local lines = {}
  local text = ""

  for line in body:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  local input_tokens = 0
  local output_tokens = 0

  for _, line in ipairs(lines) do
    local data = vim.fn.json_decode(line)
    if data.reponse then
      text = text .. data.response
    end
    if data.prompt_eval_count then
      input_tokens = data.prompt_eval_count
    end
    if data.eval_count then
      output_tokens = data.eval_count
    end
  end

  return text, input_tokens, output_tokens
end

return {
  create_service = source.create_service
}
