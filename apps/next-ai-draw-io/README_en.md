# Next AI Draw.io

<div align="center">

**AI-Powered Diagram Creation Tool - Chat, Draw, Visualize**

</div>

A Next.js web application with integrated AI functionality that seamlessly combines with draw.io diagrams. Create, modify, and enhance diagrams through natural language commands and AI-assisted visualization.

![](https://cdn.jsdelivr.net/gh/xiaoY233/PicList@main/public/assets/Next-AI-Drawio.png)

![](https://img.shields.io/badge/Copyright-arch3rPro-ff9800?style=flat&logo=github&logoColor=white)


## Features

-   **LLM-Powered Diagram Creation**: Use large language models to directly create and manipulate draw.io diagrams through natural language commands
-   **Image-Based Diagram Replication**: Upload existing diagrams or images and let AI automatically replicate and enhance them
-   **PDF and Text File Upload**: Upload PDF documents and text files, extract content and generate diagrams from existing documents
-   **AI Reasoning Process Display**: View AI thinking processes of supported models (OpenAI o1/o3, Gemini, Claude, etc.)
-   **Diagram History**: Comprehensive version control that tracks all changes, allowing you to view and restore diagram versions before AI edits
-   **Interactive Chat Interface**: Real-time conversation with AI to refine your diagrams
-   **Cloud Architecture Diagram Support**: Specialized support for generating cloud architecture diagrams (AWS, GCP, Azure)
-   **Animated Connectors**: Create dynamic animated connectors between diagram elements for better visualization

## Quick Start

### Try Online

No installation required! Try directly on our demo site:

[Live Demo](https://next-ai-drawio.jiang.jp/)

> Note: Due to high traffic, the demo site currently uses the minimax-m2 model. For best results, it is recommended to use Claude Sonnet 4.5 or Claude Opus 4.5 for self-deployment.

> **Use Your Own API Key**: You can use your own API Key to bypass usage limits on the demo site. Click the settings icon in the chat panel to configure your Provider and API Key. Your Key is only saved locally in your browser and will not be stored on the server.


3. Configure your AI provider:

Edit `.env.local` and configure your chosen provider:

-   Set `AI_PROVIDER` to your chosen provider (bedrock, openai, anthropic, google, azure, ollama, openrouter, deepseek, siliconflow)
-   Set `AI_MODEL` to the specific model you want to use
-   Add the API key required by your provider
-   `TEMPERATURE`: Optional temperature setting (e.g. `0` for deterministic output). Do not set this parameter for models that do not support it (such as reasoning models).
-   `ACCESS_CODE_LIST` Access password, optional, you can use commas to separate multiple passwords.

> Warning: If you do not fill in `ACCESS_CODE_LIST`, anyone can directly use your deployed website, which may cause your tokens to be consumed rapidly. It is recommended to fill in this option.

For detailed setting instructions, please refer to the [Provider Configuration Guide](https://github.com/DayuanJiang/next-ai-draw-io/blob/main/docs/ai-providers.md).

## Multi-Provider Support

-   AWS Bedrock (default)
-   OpenAI
-   Anthropic
-   Google AI
-   Azure OpenAI
-   Ollama
-   OpenRouter
-   DeepSeek
-   SiliconFlow

All providers except AWS Bedrock and OpenRouter support custom endpoints.

📖 **[Detailed Provider Configuration Guide](https://github.com/DayuanJiang/next-ai-draw-io/blob/main/docs/ai-providers.md)** - View setup instructions for each provider.

**Model Requirements**: This task requires strong model capabilities as it involves generating long text (draw.io XML) with strict format constraints. Recommended to use Claude Sonnet 4.5, GPT-4o, Gemini 2.0 and DeepSeek V3/R1.

Note: `claude-sonnet-4-5` has been trained on draw.io diagrams with AWS flags, so this is the best choice if you want to create AWS architecture diagrams.