# Chatty-AI OpenAI service

This is a plugin that enables support for completions by OpenAI's ChatGPT models, and this is only useful used in conjunction with [chatty-ai](https://github.com/justinhj/chatty-ai.nvim).

## Usage

After installing the chatty-ai system, you should also register for an OpenAI account and obtain an API key. Once you have the key please set it as an environment variable named `OPENAI_API_KEY` (configurable), so that it can be accessed by the plugin when making completions.

In [./sampleconfig/config.lua](./sampleconfig/config.lua) you can find simple instructions to do this.
