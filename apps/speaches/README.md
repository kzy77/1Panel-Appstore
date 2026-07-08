# Speaches 介绍

## Speaches

`speaches` 是一个兼容 OpenAI API 的服务端，支持流式转写（transcription）、翻译（translation）以及语音生成（speech generation）。语音转文本（Speech-to-Text）由 [faster-whisper](https://github.com/SYSTRAN/faster-whisper) 驱动；文本转语音（Text-to-Speech）则使用 [piper](https://github.com/rhasspy/piper) 和 [Kokoro](https://huggingface.co/hexgrad/Kokoro-82M)。该项目的目标是成为“面向 TTS/STT 模型的 Ollama”。

## 功能特性

- 兼容 OpenAI API：所有可对接 OpenAI API 的工具与 SDK，原则上都可以对接 `speaches`。
- 音频生成（chat completions 接口）｜[OpenAI 文档](https://platform.openai.com/docs/guides/realtime)
  - 生成一段文本的语音摘要（文本输入，音频输出）
  - 对一段录音进行情感分析（音频输入，文本输出）
  - 与模型进行异步的语音到语音交互（音频输入，音频输出）
- 支持流式输出（转写过程通过 SSE 持续推送；无需等待整段音频完全转写后再获取结果）。
- 动态模型加载/卸载：在请求中指定要使用的模型即可自动加载；闲置一段时间后会自动卸载。
- 文本转语音（TTS）：支持 `kokoro`（在 [TTS Arena](https://huggingface.co/spaces/Pendrokar/TTS-Spaces-Arena) 排名第 1）与 `piper` 模型。
- 支持 GPU 与 CPU。
- 支持通过 [Docker Compose / Docker 部署](https://speaches.ai/installation/)
- 支持 [Realtime API](https://speaches.ai/usage/realtime-api)
- 支持 [高度可配置](https://speaches.ai/configuration/)

---
如需更详细的部署与集成说明，请参考 [Speaches 官方文档](https://speaches.ai)。

## 1Panel 部署说明

- 当前包使用 `ghcr.io/speaches-ai/speaches:0.8.3-cuda` 镜像，需要可用的 NVIDIA GPU / Container Toolkit。
- Hugging Face 模型缓存会持久化到 `./data/hf-hub-cache`，避免容器重建后重复下载模型。
- 默认启用 API Key 保护，请在安装表单中设置 `SECRET_KEY`。
