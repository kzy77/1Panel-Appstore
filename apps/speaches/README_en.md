# Speaches Introduction

## Speaches

`speaches` is an OpenAI API-compatible server supporting streaming transcription, translation, and speech generation. Speach-to-Text is powered by [faster-whisper](https://github.com/SYSTRAN/faster-whisper) and for Text-to-Speech [piper](https://github.com/rhasspy/piper) and [Kokoro](https://huggingface.co/hexgrad/Kokoro-82M) are used. This project aims to be Ollama, but for TTS/STT models.

## Features:

- OpenAI API compatible. All tools and SDKs that work with OpenAI's API should work with `speaches`.
- Audio generation (chat completions endpoint) | [OpenAI Documentation](https://platform.openai.com/docs/guides/realtime)
  - Generate a spoken audio summary of a body of text (text in, audio out)
  - Perform sentiment analysis on a recording (audio in, text out)
  - Async speech to speech interactions with a model (audio in, audio out)
- Streaming support (transcription is sent via SSE as the audio is transcribed. You don't need to wait for the audio to fully be transcribed before receiving it).
- Dynamic model loading / offloading. Just specify which model you want to use in the request and it will be loaded automatically. It will then be unloaded after a period of inactivity.
- Text-to-Speech via `kokoro`(Ranked #1 in the [TTS Arena](https://huggingface.co/spaces/Pendrokar/TTS-Spaces-Arena)) and `piper` models.
- GPU and CPU support.
- [Deployable via Docker Compose / Docker](https://speaches.ai/installation/)
- [Realtime API](https://speaches.ai/usage/realtime-api)
- [Highly configurable](https://speaches.ai/configuration/)

---
For detailed deployment and integration documentation, please refer to [Speaches Official Documentation](https://speaches.ai).

## 1Panel Deployment Notes

- This package uses the `ghcr.io/speaches-ai/speaches:0.8.3-cuda` image and requires an available NVIDIA GPU / Container Toolkit.
- The Hugging Face model cache is persisted under `./data/hf-hub-cache` to avoid re-downloading models after container recreation.
- API key protection is enabled by default. Set `SECRET_KEY` in the install form.
