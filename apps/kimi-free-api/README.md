### 工具介绍

🚀 KIMI AI 长文本大模型逆向API【特长：长文本解读整理】，支持高速流式输出、智能体对话、联网搜索、探索版、K1思考模型、长文档解读、图像解析、多轮对话，零配置部署，多路token支持，自动清理会话痕迹，仅供测试，如需商用请前往官方开放平台。

![](https://cdn.jsdelivr.net/gh/xiaoY233/PicList@main/public/assets/Free-API.png)

![](https://img.shields.io/badge/Copyright-arch3rPro-ff9800?style=flat&logo=github&logoColor=white)

### 风险说明

- 逆向API是不稳定的，建议前往Kimi官方 https://platform.moonshot.cn/ 付费使用API，避免封禁的风险。

- 本组织和个人不接受任何资金捐助和交易，此项目是纯粹研究交流学习性质！

- 仅限自用，禁止对外提供服务或商用，避免对官方造成服务压力，否则风险自担！


### 修改原因

- 原项目作者账号被封，无法更新了
- 已去除原项目中包含的恶意代码，欢迎对本项目源码进行审查

### 更新说明
1. 更新models.ts 模型列表，支持kimi-k2-0905-preview、kimi-k2-thinking、kimi-latest等最新模型
2. 重新打包新版本的docker镜像，akashrajpuroh1t/kimi-free-api-fix:latest
3. 已修复源码中恶意代码问题，并重新打包，原项目包含混淆代码在src/api/chat.js文件末尾处

> PS：模型名称实际上并没啥用，只是方便和好看，实际上线上Chat调用是啥模型，就用的啥模型，模型名称随便填都可以。

### 使用说明

从 [kimi.moonshot.cn](https://kimi.moonshot.cn/) 获取refresh_token

进入kimi随便发起一个对话，然后F12打开开发者工具，从Application > Local Storage中找到`refresh_token`的值，复制这个值填写到Lobechat或者CherryStudio等工具中，作为API密钥，API地址是你部署应用的IP加端口，例如:`https://192.168.1.105:8001/v1/chat/completions`，注意某些工具只需要填写`https://192.168.1.105:8001/`即可。

![获取token](https://cdn.jsdelivr.net/gh/LLM-Red-Team/kimi-free-api@master/doc/example-0.png)

如果你看到的`refresh_token`是一个数组，请使用`.`拼接起来再使用。

![example8](https://cdn.jsdelivr.net/gh/LLM-Red-Team/kimi-free-api@master/doc/example-8.jpg)


### 支持K2模型

Kimi K2 是一款先进的混合专家 (MoE) 语言模型，拥有 320 亿个激活参数和 1 万亿个总参数。Kimi K2 采用 Muon 优化器进行训练，在前沿知识、推理和编码任务中表现出色，同时针对代理能力进行了精心优化

当前版本支持K2模型使用，需要手动添加模型，模型ID为`kimi-k2-0711-preview`, 模型名称随便填写

![](https://cdn.jsdelivr.net/gh/xiaoY233/PicList@main/public/assets/Kimi-K2.png)


### 多账号接入

目前同个账号同时只能有*一路*输出，你可以通过提供多个账号的userToken value并使用`,`拼接提供：

```
API密钥：TOKEN1,TOKEN2,TOKEN3
```

每次请求服务会从中挑选一个。
