local chatty = require('chatty-ai')

-- https://platform.openai.com/docs/api-reference/chat

-- > curl https://api.openai.com/v1/chat/completions \
--   -H "Content-Type: application/json" \
--   -H "Authorization: Bearer $OPENAI_API_KEY" \
--   -d '{
--      "model": "gpt-4o",
--      "messages": [{"role": "user", "content": "Say this is a test!"}],
--      "temperature": 0.7
--    }'

-- chunk response
-- {"id":"chatcmpl-123","object":"chat.completion.chunk","created":1694268190,"model":"gpt-4o-mini", "system_fingerprint": "fp_44709d6fcb", "choices":[{"index":0,"delta":{"role":"assistant","content":""},"logprobs":null,"finish_reason":null}]}

-- {"id":"chatcmpl-123","object":"chat.completion.chunk","created":1694268190,"model":"gpt-4o-mini", "system_fingerprint": "fp_44709d6fcb", "choices":[{"index":0,"delta":{},"logprobs":null,"finish_reason":"stop"}]}


---@class CompletionServiceConfig
---@field public name string
---@field public stream_error_cb function
---@field public stream_complete_cb function
---@field public error_cb function
---@field public complete_cb function
---@field public stream_cb function
---@field public configure_call function

---@class OpenAIConfig
---@field api_key_name string?
---@field model string?

---@type OpenAIConfig
local default_config = {
  api_key_name = 'OPENAI_API_KEY',
  model = 'gpt-4o',
}

local OPENAI_URL = 'https://api.openai.com/v1/chat/completions'

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
  local url = OPENAI_URL
  local api_key = os.getenv(config.api_key_name)
  if not api_key then
    error('OpenAI api key \'' .. config.api_key_name .. '\' not found in environment.')
  end
  local headers = {
      ['Authorization'] = 'Bearer ' .. api_key,
      ['Content-Type'] = 'application/json',
    }

  local body = {
    model = config.model,
    messages = {
      { role = 'system',
        content = completion_config.system
      },
      { role = 'user',
        content = user_prompt,
      },
    }
  }

  if is_stream then
    body['stream'] = true
    body['stream_options'] = { include_usage = is_stream }
  end

  vim.print(vim.inspect(headers) .. vim.inspect(body))
  return url, headers, body
end

source.complete_cb = function(response)
  local status, parsed_response = pcall(vim.fn.json_decode, response.body)
  if status then
    local input_tokens = parsed_response.usage.prompt_tokens or 0
    local output_tokens = parsed_response.usage.completion_tokens or 0
    local content = ''
    local choice = parsed_response.choices[1]
    content = choice.message.content

    return {
      content = content,
      input_tokens = input_tokens,
      output_tokens = output_tokens,
    }
  else
    error(parsed_response)
  end
end

source.stream_cb = function(raw_chunk)
  local chunk = raw_chunk:gsub("^data: ", "")
  if #chunk == 0 or chunk == '[DONE]' then
    return ''
  else
    local status, data = pcall(vim.json.decode, chunk)
    local content = ''
    if status then
      if #data.choices == 0 or data.choices[1].finish_reason == 'stop' then
        return ''
      elseif data.choices and data.choices[1].delta then
        content = data.choices[1].delta.content
      end
      return content
    else
      error(data)
    end
    return content
  end
end

source.stream_complete_cb = function(response)
  local body = response.body
  local lines = {}

  for line in body:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  local input_tokens = 0
  local output_tokens = 0
  local content = ''

  for _, raw_chunk in ipairs(lines) do
    local chunk = raw_chunk:gsub("^data: ", "")
    if #chunk == 0 or chunk == '[DONE]' then
      return content, input_tokens, output_tokens
    else
      local status, data = pcall(vim.json.decode, chunk)
      local content = ''
      if status then
        if #data.choices == 0 or data.choices[1].finish_reason == 'stop' then
        elseif data.choices and data.choices[1].delta then
          content = content .. data.choices[1].delta.content
        elseif data.usage and type(data.usage) == 'table' then
          input_tokens = data.usage.prompt_tokens
          output_tokens = data.usage.completion_tokens
        end
      else
        error(data)
      end
    end
  end
end

return {
  create_service = source.create_service
}
