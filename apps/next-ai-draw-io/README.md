# Next AI Draw.io

<div align="center">

**AI驱动的图表创建工具 - 对话、绘制、可视化**

</div>

一个集成了AI功能的Next.js网页应用，与draw.io图表无缝结合。通过自然语言命令和AI辅助可视化来创建、修改和增强图表。

![](https://cdn.jsdelivr.net/gh/xiaoY233/PicList@main/public/assets/Next-AI-Drawio.png)

![](https://img.shields.io/badge/Copyright-arch3rPro-ff9800?style=flat&logo=github&logoColor=white)


## 功能特性

-   **LLM驱动的图表创建**：利用大语言模型通过自然语言命令直接创建和操作draw.io图表
-   **基于图像的图表复制**：上传现有图表或图像，让AI自动复制和增强
-   **PDF和文本文件上传**：上传PDF文档和文本文件，提取内容并从现有文档生成图表
-   **AI推理过程显示**：查看支持模型的AI思考过程（OpenAI o1/o3、Gemini、Claude等）
-   **图表历史记录**：全面的版本控制，跟踪所有更改，允许您查看和恢复AI编辑前的图表版本
-   **交互式聊天界面**：与AI实时对话来完善您的图表
-   **云架构图支持**：专门支持生成云架构图（AWS、GCP、Azure）
-   **动画连接器**：在图表元素之间创建动态动画连接器，实现更好的可视化效果

## 快速开始

### 在线试用

无需安装！直接在我们的演示站点试用：

[Live Demo](https://next-ai-drawio.jiang.jp/)

> 注意：由于访问量较大，演示站点目前使用 minimax-m2 模型。如需获得最佳效果，建议使用 Claude Sonnet 4.5 或 Claude Opus 4.5 自行部署。

> **使用自己的 API Key**：您可以使用自己的 API Key 来绕过演示站点的用量限制。点击聊天面板中的设置图标即可配置您的 Provider 和 API Key。您的 Key 仅保存在浏览器本地，不会被存储在服务器上。


3. 配置您的AI提供商：

编辑 `.env.local` 并配置您选择的提供商：

-   将 `AI_PROVIDER` 设置为您选择的提供商（bedrock, openai, anthropic, google, azure, ollama, openrouter, deepseek, siliconflow）
-   将 `AI_MODEL` 设置为您要使用的特定模型
-   添加您的提供商所需的API密钥
-   `TEMPERATURE`：可选的温度设置（例如 `0` 表示确定性输出）。对于不支持此参数的模型（如推理模型），请不要设置。
-   `ACCESS_CODE_LIST` 访问密码，可选，可以使用逗号隔开多个密码。

> 警告：如果不填写 `ACCESS_CODE_LIST`，则任何人都可以直接使用你部署后的网站，可能会导致你的 token 被急速消耗完毕，建议填写此选项。

详细设置说明请参阅[提供商配置指南](https://github.com/DayuanJiang/next-ai-draw-io/blob/main/docs/ai-providers.md)。

## 多提供商支持

-   AWS Bedrock（默认）
-   OpenAI
-   Anthropic
-   Google AI
-   Azure OpenAI
-   Ollama
-   OpenRouter
-   DeepSeek
-   SiliconFlow

除AWS Bedrock和OpenRouter外，所有提供商都支持自定义端点。

📖 **[详细的提供商配置指南](https://github.com/DayuanJiang/next-ai-draw-io/blob/main/docs/ai-providers.md)** - 查看各提供商的设置说明。

**模型要求**：此任务需要强大的模型能力，因为它涉及生成具有严格格式约束的长文本（draw.io XML）。推荐使用Claude Sonnet 4.5、GPT-4o、Gemini 2.0和DeepSeek V3/R1。

注意：`claude-sonnet-4-5` 已在带有AWS标志的draw.io图表上进行训练，因此如果您想创建AWS架构图，这是最佳选择。