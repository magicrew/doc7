<div align="center">
  <h1>doc7</h1>
  <p><strong>一切文档，直接变成 AI 可用的 Markdown。</strong></p>
  <p>把 PDF、Office、扫描件、截图、图表、公式和流程图，转换成 AI 可以检索、引用和理解的知识。</p>
  <p>简体中文 · <a href="./README.md">English</a></p>
  <p><a href="https://github.com/magicrew/doc7">GitHub</a> · <a href="https://github.com/magicrew/doc7/releases">下载发行包</a> · <a href="./benchmarks/attention-is-all-you-need/README.md">Benchmark</a></p>
</div>

[![构建状态](https://github.com/magicrew/doc7/actions/workflows/build.yml/badge.svg)](https://github.com/magicrew/doc7/actions/workflows/build.yml) [![最新发行版](https://img.shields.io/github/v/release/magicrew/doc7?display_name=tag)](https://github.com/magicrew/doc7/releases) [![开源许可证：MIT](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

[![doc7 将一切文档转换为 AI 可用的 Markdown](./assets/readme/hero/hero.zh-CN.webp)](#快速开始)

doc7 通过你自己的 OpenAI 兼容多模态模型，把 PDF、Office、扫描件、截图、
图表、公式和流程图转换为 Markdown。无需专用 OCR 技术栈，不绑定文档处理
服务。

## 快速开始

**直接下载：** [macOS、Linux 和 Windows CLI 压缩包](https://github.com/magicrew/doc7/releases)

不需要管理员权限，直接安装最新发行版。

macOS 或 Linux：

```bash
curl -fsSL https://raw.githubusercontent.com/magicrew/doc7/main/scripts/install.sh | bash
```

Windows PowerShell：

```powershell
irm https://raw.githubusercontent.com/magicrew/doc7/main/scripts/install.ps1 | iex
```

macOS 推荐使用上面的安装脚本。它会下载并校验发行包，然后安装到当前用户目录，
不需要管理员权限，也不要求 Apple Developer ID。直接用浏览器下载并打开二进制文件
是另一条路径：macOS 可能会给文件添加隔离属性。若选择直接下载压缩包，请在终端
解压后执行发行包中对应的命令：

```bash
xattr -dr com.apple.quarantine <解压后的目录>
```

这只会移除当前下载文件的本地隔离属性，不等同于 Apple 签名或公证。正式的 Developer
ID 签名和公证需要 Apple Developer Program 账号，后续可以为正式发行通道接入。

启动 LM Studio 或 Ollama，加载一个本地视觉模型，然后直接转换文件：

```bash
doc7 报告.pdf
doc7 截图.png
```

首次运行就是完整配置流程。doc7 会自动检测系统语言，查找正在运行的本地模型
服务，读取服务实际提供的模型 ID；存在多个模型时让用户选择，验证图像理解能力，
并把选择保存在当前机器。无需鉴权的 LM Studio 和 Ollama 本地接口不需要 Key。

`chat` 是运行在当前本地模型上的轻量 Agent。普通消息直接对话，不要求包含
文件；不带参数时进入持续会话：

```bash
doc7 chat "你好，请介绍一下你自己"
doc7 chat
```

当用户明确提供文件、目录或网址并要求处理时，模型可以调用受限的
`convert_document` 工具：

```bash
doc7 chat "把报告.pdf 转换成适合知识库检索的 Markdown"
```

这里没有中文关键词或固定句式判断。模型通过 OpenAI 兼容 Tool Calling 决定
是否调用工具。用户只提供模糊文件名时，Chat 可以在已授权目录中使用结构化的
只读文件工具（`pwd`、`ls`、`find`、`file`、`stat`、`wc`、`realpath`）查看文件
元数据，再让用户选择候选文件。它不会接收任意 Shell 字符串，不支持管道、重定向、
脚本、写入、网络命令或进程控制。

会话默认授权当前工作目录，以及存在的 Desktop、Documents、Downloads 目录。
访问其他目录时，必须由用户在本地终端输入并授权。`head` 和 `tail` 会把有限的
文本内容交给模型，因此被单独限制，并且需要用户确认后才能使用。模型不支持
Tool Calling 时仍可正常聊天，文档转换继续使用稳定入口 `doc7 <文件>`。

`chat` 也可以帮助配置 doc7。它会查看当前配置、发现 LM Studio 或 Ollama
已经暴露的模型，并发送真实的小图片请求验证视觉能力：

```text
doc7> 使用本地 LM Studio，选择一个能看图的模型
doc7> 把界面改成英文
doc7> 检查现在的模型配置能不能用
```

涉及写入的操作先做 dry-run，再调用 `ask_user` 展示选项。只有你在终端选择确认后
才会保存配置；`doc7 --yes chat "..."` 可以对本次非敏感配置变更提供显式自动确认。
远程接口需要 API Key 时，Chat 可以发起本地隐藏输入。模型可以看到输入字节数和
凭据来源，但看不到 Key 内容。非交互环境使用 `doc7 setup config --api-key-stdin`。

查看或修改本机配置：

```bash
doc7 config show
doc7 config path
doc7 config set              # 列出所有可编辑 Key、当前值和说明
doc7 config set language zh-CN    # en、zh-CN 或 auto
doc7 setup                        # 重新查找本地模型
```

`doc7 config` 会显示实际生效的配置文件路径。中文标签旁边保留稳定的英文
Key，修改时可以直接使用：

```bash
doc7 config set model <模型 ID>
doc7 config set base_url http://127.0.0.1:1234/v1
doc7 config set credential_store env
```

配置文件通常位于用户配置目录下的 `doc7/config.yaml`；如果当前目录或父目录
存在 `.doc7.yaml`，doc7 会显示并使用那个实际生效的路径。也可以通过
`--config <路径>` 明确指定配置文件。

升级已安装的 CLI：

```bash
doc7 update --check
doc7 update
```

更新只读取 GitHub 最新正式 Release，下载当前平台包并校验 `checksums.txt`。
Windows 会在程序退出后替换正在运行的 exe；安装目录需要当前用户拥有写权限。

也可以连接远程 OpenAI 兼容接口。首次向远程接口转换前，doc7 会明确提示文档
内容将离开当前机器。API Key 只保存在系统钥匙串、Windows 凭据管理器、用户
明确指定的环境变量或本机凭据文件中，不会写入仓库或发行包。

Windows x86_64 普通压缩包包含 CLI 和启动脚本。Windows Portable 包还会
携带文档渲染器，受管控的机器可以解压到 `C:\doc7` 之类的短路径直接运行。
模型不会打包进 CLI，doc7 始终使用你自己配置的本地或私有模型接口。

## 本地模型，接近零边际成本

doc7 不出售文档额度，也不按页、按图片或按转换次数收费。把量化多模态模型
运行在自己的笔记本、工作站、服务器或私有推理机器上，只要硬件能够继续处理，
就不会因为多转换一页而产生新的 doc7 账单。已有硬件能够承载模型时，新增
一份文档的边际成本主要只剩电力和运行时间。

- **没有文档 API 计价器。** 重复转换和大批量处理不会按每一页持续累加
  doc7 费用。
- **使用已有硬件。** 量化开源模型可以把现有 CPU、GPU 或统一内存变成可重复
  使用的文档理解接口。
- **一个模型处理多种信息。** 正文、表格、公式、图表、流程关系、截图和图像
  含义由同一个视觉模型理解，不需要分别维护 OCR、版面、表格和公式模型。
- **文档留在自己的环境。** 本地或私有接口让文档内容停留在用户控制的基础
  设施内。

只要内存能够容纳对应权重，小型量化视觉模型就能在配置不高的机器上运行。
实际速度、效果和最低配置由用户选择的模型及量化方式决定；doc7 不限定模型
规模，也不承诺所有模型产生相同结果。

## 本地推理与云文档 API 的成本结构

云服务价格会随地区、版本、功能和用量变化。长期差异在于计费结构：云文档
API 通常按页、图片或功能调用计费；本地 doc7 的主要成本是用户自己控制的
硬件、电力和运行维护。

| 方案 | 常见计费单位 | 文档量增长后的成本 | 文档位置 |
| --- | --- | --- | --- |
| **doc7 + 本地量化视觉模型** | doc7 不按页或调用收费 | 主要是已有硬件、电力和运行维护 | 本地或私有基础设施 |
| [AWS Textract](https://aws.amazon.com/textract/pricing/) | 按页面、API 和分析功能计费 | 页面和启用功能越多，用量越高 | 云 API |
| [Google Document AI](https://cloud.google.com/products/document-ai/pricing) | 通常按页面、处理器和用量档位计费 | 页面和处理器类型决定持续用量 | 云 API |
| [Azure Document Intelligence](https://azure.microsoft.com/en-us/pricing/details/document-intelligence/) | 按页面、模型和定价层级计费 | 页面和所选能力决定持续用量 | 云 API |
| [阿里云 OCR](https://help.aliyun.com/zh/ocr/product-overview/product-billing/) | 按量调用或预付费资源包 | 持续处理会消耗调用量或资源包额度 | 云 API |
| [腾讯云 OCR](https://buy.cloud.tencent.com/price/ocr) | API 调用的预付费或后付费计费 | 持续处理会消耗调用次数或资源包额度 | 云 API |
| [百度智能云 OCR](https://cloud.baidu.com/doc/OCR/s/Jk3h7xtsd) | API 调用、免费额度和付费用量 | 持续处理会消耗调用次数或额度 | 云 API |

如果团队需要托管容量、不想运行模型，云 API 仍然有价值。doc7 面向另一种
选择：复用本地或私有模型，取消持续累加的文档解析账单，把长期文档转换能力
变成自己拥有的基础设施。

## 高复杂度论文，也能精准转换

[![doc7 将 Attention Is All You Need 转换成 AI 可用的 Markdown](./examples/attention-is-all-you-need/showcase.zh-CN.webp)](./examples/attention-is-all-you-need/input.webp)

《Attention Is All You Need》中的一页纯图片 PDF，没有文本层。doc7
把论文身份、Figure 2、展示公式、缩放原因、技术脚注，以及两张注意力图
内部的顺序和并行关系，完整转换为可检索的 Markdown。

同一套流程也可以处理完整论文和多页报告，再按原始页序重建为一份文档。

doc7 读取整页信息，而不止字符。你可以接入任何兼容 OpenAI 接口的多模态模型，包括本地模型和私有化部署。doc7 不要求单独搭建 OCR 技术栈，也不收取按页处理费用。

## 公开 Benchmark

[![doc7 视觉理解 Benchmark](./assets/readme/benchmark/benchmark.zh-CN.webp)](./benchmarks/visual-report/README.md)

两份纯图片 PDF，15 项可机器校验的视觉事实。MarkItDown OCR 与 doc7
通过同一个本地 OpenAI 兼容接口使用同一个 `qwen3.5-9b` 模型，Docling
使用标准本地流水线。

| 系统 | Attention 论文 | 视觉报告 | 合计 | 原始 Markdown |
| --- | ---: | ---: | ---: | ---: |
| **#1 doc7 + qwen3.5-9b** | **7/7** | **8/8** | **15/15** | **5,293 字节** |
| MarkItDown 0.1.6 + OCR 0.1.0 + qwen3.5-9b | 3/7 | 6/8 | 9/15 | 13,142 字节 |
| Docling 2.113.0 标准模式 | 1/7 | 2/8 | 3/15 | 2,571,445 字节 |
| MarkItDown 0.1.6 默认模式 | N/A | N/A | N/A | 0 字节 |

论文案例检查论文身份、Figure 2、两张注意力图的有序关系、展示公式、缩放
原因和技术脚注。视觉报告检查正文、KPI、图表数据与趋势、表格、公式语义与
LaTeX、工作流顺序和界面状态。

MarkItDown 默认模式对两份纯图片输入都生成了空文件，因此标记为 `N/A`，
不把输入限制伪装成产品能力 0 分；官方 OCR 插件单独参与评分。Docling 的
Markdown 体积较大，是因为其中嵌入了 Base64 页面图像；字节数只作为诊断
信息，不代表质量。

[查看 Attention 输入](./examples/attention-is-all-you-need/input.pdf) · [查看 doc7 输出](./examples/attention-is-all-you-need/output.md) · [查看 Attention Benchmark](./benchmarks/attention-is-all-you-need/README.md) · [查看视觉报告 Benchmark](./benchmarks/visual-report/README.md)

运行信息：`2026-07-30` · `darwin/arm64`。仓库保留全部原始输出、SHA-256、
评分规则和机器可读结果，不包含模型接口地址和凭据。

这两项测试聚焦整页视觉理解，不代表所有文档上的绝对排名。论文输入基于
《Attention Is All You Need》第 4 页制作，用于带署名的学术评估，不属于
doc7 的 MIT 许可证范围。[查看来源和授权记录](./examples/attention-is-all-you-need/source.json)。

需要大规模评估时，使用 [olmOCR-Bench 适配器](./benchmarks/olmocr/README.md)。它支持上游固定版本的 1,403 份 PDF、7,010 个机器可判定事实，不把第三方文档打包进 doc7；在完整、固定版本的运行完成前，doc7 不发布全量排名结论。

## 一套流程，处理一切文档

[![doc7 使用一套视觉理解流程处理一切文档](./assets/readme/formats/formats.zh-CN.webp)](#支持的输入)

不同格式进入同一套页面理解流程。正文、表格、公式、图表、图示关系、图像
含义和可见界面状态，最终组成一份可检索的 Markdown 文档。

## doc7 选择了另一条路线

| 主要路线 | 代表项目 | 处理方式 | 需要维护的东西 |
| --- | --- | --- | --- |
| 格式解析和文本提取 | [MarkItDown](https://github.com/microsoft/markitdown) 默认路径 | 针对不同文件格式提取文本和基础结构 | Python 依赖和可选插件 |
| 视觉模型 OCR 封装 | [Zerox](https://github.com/getomni-ai/zerox) | 将页面转成图像，再交给特定厂商的视觉 SDK | Node/Python SDK、GraphicsMagick/Ghostscript 和厂商凭据 |
| 专用文档 AI 技术栈 | [MinerU](https://github.com/opendatalab/MinerU)、[Docling](https://github.com/docling-project/docling) | OCR、版面、表格、公式和文档模型组成处理流水线 | 模型权重、运行环境和专用基础设施 |
| 整页视觉理解 | **doc7** | 先把页面渲染成图像，再交给你的多模态模型重建 Markdown | 跨平台 CLI、Go SDK、MCP 工具、异步 HTTP 服务和已有模型接口 |

模型由用户决定。doc7 不预设模型规模，也不会宣传没有实测过的模型效果。接入私有化开源模型后，不再需要购买专门的文档解析服务，也没有 doc7 处理额度。

## 命令行就是产品入口

[![doc7 在 macOS、Linux 和 Windows 上的命令行界面](./assets/readme/cli/cli.zh-CN.webp)](#快速开始)

同一个二进制文件提供交互式 CLI、批量处理、模型检查、MCP、Go SDK 和异步
HTTP 服务。

## 模型、依赖与失败恢复

先查看兼容 OpenAI 的视觉模型接口实际提供的模型 ID：

```bash
doc7 models --base-url http://localhost:8000/v1
```

LM Studio 默认使用 `http://127.0.0.1:1234/v1`。启动 LM Studio 的本地服务后，使用这个地址和接口返回的某个模型 ID 即可。

再保存接口地址和其中一个真实模型 ID：

```bash
doc7 setup config \
  --base-url http://localhost:8000/v1 \
  --model <model-id>
```

需要鉴权时，可以设置 `DOC7_API_KEY`，也可以使用 `doc7 setup config --api-key-stdin`。如果要使用其他环境变量，必须通过 `--api-key-env` 明确指定，例如 `--api-key-env OPENAI_API_KEY`。doc7 不会自动扫描各家模型的环境变量，避免把本机密钥发送到任意私有端点。不需要鉴权的本地或私有接口无需填写占位密钥，doc7 不会发送 `Authorization` 请求头。

检查本地依赖，并向模型发送一次真实的小图片请求：

```bash
doc7 doctor --check-model
```

把即将处理的文件传给 doctor，可以严格检查该格式所需的依赖：

```bash
doc7 doctor report.docx --check-model
```

转换一个文档：

```bash
doc7 read report.pdf -o report-doc7
```

如果某几页需要换模型或调整参数，可以只重跑指定的原始页。页码从 `1`
开始，范围两端都包含；输出和 manifest 会保留原始页码：

```bash
doc7 read report.pdf -o report-pages-5-7 --pages 5,7
doc7 read report.pdf -o report-pages-10-12 --pages 10-12
```

manifest 会同时记录 `source_page_count` 和 `page_selection`，选中的页面仍然
会写成 `page_005.md`、`page_007.md` 等原始页码文件。manifest 和页面 metadata
中的产物路径都相对于输出目录，整个结果可以直接移动到另一台机器后使用。

长文档只有少数页面失败时，可以直接恢复原输出，不需要全部重跑：

```bash
doc7 read report.pdf -o report-doc7 --resume
doc7 read report.pdf -o report-doc7 --resume --pages 5,7
```

不传 `--pages` 时，doc7 会自动选择现有 manifest 中的全部失败页；显式页码只能
是失败页的子集，并且输入 SHA-256 必须保持一致。成功页的 Markdown 不会改动。
旧 manifest 会归档到 `history/`，新 manifest 会记录本次处理页数、保留页数和
逐页模型来源，也能准确表达混合模型结果。如果已经没有失败页，`--resume` 会
校验逐页产物并重建缺失的合并 Markdown，不会请求模型。

把合并后的 Markdown 直接输出给其他工具：

```bash
doc7 read report.pdf --stdout > report.md
```

从 stdin 读取二进制文档时，需要同时提供文件名和扩展名：

```bash
cat report.pdf | doc7 read - --stdin-name report.pdf --stdout > report.md
```

stdin 输入默认限制为 1,024 MB，可以通过 `--stdin-max-mb` 调整。

递归处理一个资料目录：

```bash
doc7 read ./documents -o ./knowledge
```

处理大目录时，`--file-workers` 控制同时处理的文档数量，`--workers` 控制单个文档内部的页面请求并发数。文件级并发默认是 `1`；只有在本地渲染器和模型接口能够承受总负载时再提高它。

直接处理远程文档：

```bash
doc7 read https://example.com/report.pdf -o ./report-doc7
```

## 作为服务运行

启动本地异步 HTTP 服务：

```bash
doc7 serve --addr 127.0.0.1:8787 --data-dir ./doc7-server
```

提交一个本地文档或 ZIP：

```bash
curl -F file=@report.pdf http://127.0.0.1:8787/v1/jobs
```

HTTP 服务也接受相同的页面选择字段：

```bash
curl -F file=@report.pdf -F pages=5,7 http://127.0.0.1:8787/v1/jobs
```

响应会返回任务 ID。轮询状态接口，完成后下载合并 Markdown 或完整产物 ZIP：

```bash
curl http://127.0.0.1:8787/v1/jobs/<job-id>
curl -o report.md http://127.0.0.1:8787/v1/jobs/<job-id>/markdown
curl -o report-artifacts.zip http://127.0.0.1:8787/v1/jobs/<job-id>/artifacts
```

在同一个任务中恢复全部失败页，或只恢复指定的失败页子集：

```bash
curl -X POST -H 'Content-Type: application/json' \
  -d '{}' http://127.0.0.1:8787/v1/jobs/<job-id>/resume

curl -X POST -H 'Content-Type: application/json' \
  -d '{"pages":"5,7"}' http://127.0.0.1:8787/v1/jobs/<job-id>/resume
```

恢复时使用服务当前配置的模型。可以停止服务、修改模型，再使用同一个
`--data-dir` 重启后恢复原任务。无效页码会在任务状态改变前返回
`409 resume_rejected`。

`GET /healthz` 不需要鉴权。监听非本机地址时必须配置 Bearer token，通过 `--auth-token-env` 指定环境变量名，默认是 `DOC7_SERVER_TOKEN`：

```bash
DOC7_SERVER_TOKEN='replace-me' doc7 serve --addr 0.0.0.0:8787
curl -H 'Authorization: Bearer replace-me' http://127.0.0.1:8787/v1/jobs
```

服务端接收上传文件和 ZIP。需要处理 URL 时，使用 CLI 或 Go `Read` API，由调用方自行控制网络策略。

## 接入 AI 工具

doc7 内置 MCP 服务，并提供类型化的 `convert_to_markdown` 工具。让 MCP 客户端通过 stdio 启动 doc7：

```json
{
  "mcpServers": {
    "doc7": {
      "command": "/absolute/path/to/doc7",
      "args": ["mcp"],
      "env": {
        "DOC7_BASE_URL": "http://127.0.0.1:1234/v1",
        "DOC7_MODEL": "qwen3.5-0.8b",
        "DOC7_CREDENTIAL_STORE": "env"
      }
    }
  }
}
```

工具接受本地路径、目录、HTTP(S) URL 或 ZIP，并返回 Markdown 和结构化转换信息。自动创建的产物保存在用户缓存目录，也可以通过 `doc7 mcp --output-root <path>` 指定位置。恢复持久化输出时，传入相同的 `input` 和 `output_dir`，并设置 `resume: true`；`pages` 可以限制为失败页子集。

## 使用 Docker 运行

Docker 镜像包含 LibreOffice、MuPDF、Chromium 和中日韩字体，以非 root 用户运行 HTTP 服务，并通过命名卷持久化配置和任务：

```bash
export DOC7_MODEL=qwen3.5-0.8b
export DOC7_SERVER_TOKEN=replace-me
docker compose pull
docker compose up --no-build
```

公开镜像地址是 `ghcr.io/magicrew/doc7:latest`，同时包含 `linux/amd64` 和 `linux/arm64`。需要从当前源码本地构建时，改用 `docker compose up --build`。

默认模型地址是 `http://host.docker.internal:1234/v1`，Docker Desktop 上的 LM Studio 可以直接使用。需要其他模型端点时设置 `DOC7_BASE_URL`。容器健康检查通过后，可以向 `http://127.0.0.1:8787/v1/jobs` 上传文件。

如果构建环境需要代理，Docker Desktop 中不要把宿主机的 `127.0.0.1` 直接传入容器，改用容器可访问的宿主机地址：

```bash
export DOC7_BUILD_HTTP_PROXY=http://host.docker.internal:7890
export DOC7_BUILD_HTTPS_PROXY=http://host.docker.internal:7890
docker compose up --build
```

使用自己的领域提示词：

```bash
doc7 read ./reports --prompt-file ./prompt.md
```

对于带原生文本层的 PDF 和 Office 文件，可以启用精确值检查：

```bash
doc7 read report.pdf --text-grounding
```

页面图像仍是主证据。doc7 不会运行 OCR，也不会用提取文本替换视觉结果；它只使用文本层检查精确数字、代码和文档标识，并要求视觉模型确认候选校正。无法确认时保留第一遍 Markdown，并在 summary 和逐页 metadata 中写入 `grounding_warnings`。该模式可能额外调用模型，默认关闭。

模型请求固定使用 `temperature: 0`，减少同一页面重复运行时的采样波动。每页模型输出默认限制为 8,192 token。如果模型服务因为 prompt 与图片超过 context window 而直接拒绝请求，或在配置的输出上限之前因 context 不足停止生成，doc7 会自动降低请求图片分辨率并重试；原始渲染页面仍保留给产物和 grounding 使用。默认最多 fallback 两次，最长边最低降到 720 像素，可通过 `--context-fallbacks`、`--min-image-dimension`、`DOC7_CONTEXT_FALLBACKS` 和 `DOC7_MIN_IMAGE_DIMENSION` 配置。

如果模型真正达到 `--max-tokens` 上限，或者 context fallback 已耗尽，doc7 会将该页标记为失败，不会把截断的 Markdown 当作成功结果写入。fallback 成功时，逐页 metadata 会记录 `request_image_max_dimension` 和 `context_fallbacks_used`。单独增大 `--max-tokens` 无法突破模型服务的 context window。

## 在 Go 中嵌入

公开包 `github.com/magicrew/doc7` 提供与 CLI 相同的转换引擎，外部项目不需要导入 `internal` 包。如果输入可能是本地文件、目录、HTTP(S) URL 或 ZIP，使用统一的 `Read`：

```go
package main

import (
	"context"
	"log"

	"github.com/magicrew/doc7"
)

func main() {
	options := doc7.DefaultReadOptions()
	options.OutputDir = "report-doc7"
	options.BaseURL = "http://127.0.0.1:1234/v1"
	options.Model = "qwen3.5-4b"
	result, err := doc7.Read(context.Background(), "report.pdf", options)
	if err != nil {
		log.Fatal(err)
	}
	if result.Document != nil {
		log.Println(result.Document.MergedMarkdown)
	}
}
```

`Read` 会返回有类型的单文档结果或递归批处理结果。启用页面选择时，摘要会同时
提供选中的 `PagesTotal` 和源文档的 `SourcePagesTotal`。`ReadOptions`、`Options`
和 `BatchOptions` 都可以通过 `Resume` 恢复已有失败页，并用 `Pages` 限制失败页
子集。需要明确限制输入形态时，使用 `Convert` 和 `ConvertBatch`：

```go
package main

import (
	"context"

	"github.com/magicrew/doc7"
)

func main() {
	options := doc7.DefaultOptions()
	options.OutputDir = "report-doc7"
	options.BaseURL = "http://127.0.0.1:1234/v1"
	options.Model = "qwen3.5-4b"
	_, err := doc7.Convert(context.Background(), "report.pdf", options)
	if err != nil {
		panic(err)
	}
}
```

三个入口都提供有类型的结果和进度回调；启用并发时，页面和文件事件可能并行到达。

## 转换后保留下来的信息

| 页面信息 | Markdown 结果 |
| --- | --- |
| 标题、段落、列表、引用和代码 | 原生 Markdown 结构 |
| 表格和电子表格 | 保留数值、单位和表头的 Markdown 或 HTML 表格 |
| 数学公式 | 行内或块级 LaTeX |
| 图表 | 标签、数值、趋势和结论变成可检索文字 |
| 流程图和关系图 | 节点、顺序、分组和关系 |
| 截图和软件界面 | 可见状态、错误、控件和操作 |
| 邮件 | 头信息、HTML 或纯文本正文、内嵌图片和附件清单 |
| Jupyter Notebook | Markdown 单元、代码、执行计数、文本输出、异常 traceback 和视觉输出 |
| 有信息价值的排版 | 对比、层级、顺序和空间关系 |

## 支持的输入

| 类别 | 格式 |
| --- | --- |
| 文档 | PDF、DOC/DOCX/DOCM、DOT/DOTX/DOTM、ODT、RTF |
| 演示文稿 | PPT/PPTX/PPTM、POT/POTX/POTM、PPS/PPSX/PPSM、ODP |
| 电子表格 | XLS/XLSX/XLSM、XLT/XLTX/XLTM、ODS |
| 电子书 | EPUB |
| 邮件和网页存档 | EML、MHTML/MHT、Outlook MSG |
| Notebook | Jupyter Notebook（IPYNB） |
| 图片 | PNG、JPEG、GIF、WebP、BMP、TIFF（包括多页 TIFF）、SVG、有序图片目录 |
| 原生文本和数据 | Markdown、TXT、CSV、TSV、JSON、XML、YAML |
| 网页和资料包 | HTML、HTTP/HTTPS URL、ZIP、嵌套文档目录 |

Office 和 OpenDocument 文件需要 LibreOffice。PDF 优先使用 MuPDF，也支持 `doc7 doctor` 检测到的平台替代方案。HTML、SVG、EPUB、EML、MHTML/MHT、MSG 和 IPYNB 渲染需要 Chrome、Chromium 或 Edge。Windows 发行包包含可拖拽使用的批处理文件。

EML、MHTML/MHT 和 Outlook MSG 均由 doc7 原生解析，不要求安装 Microsoft Outlook。

原生文本和数据格式会在本地直接转换，不需要视觉模型；PDF、Office、图片、HTML、SVG、EPUB、邮件和 Jupyter Notebook 等视觉格式使用配置好的 OpenAI 兼容多模态接口。

## 为 AI 知识而设计

每次运行都会保存合并后的 Markdown、逐页 Markdown、页面图像、元数据和 manifest，可直接用于：

- RAG 入库和语义检索；
- Agent 知识库；
- 研究和文档分析；
- 视觉报告、截图和历史资料的全文检索；
- 需要逐页来源和处理记录的可审计流水线。

如果只需要 Markdown 和 metadata，可以使用 `--keep-images=false`。完成后会删除
渲染图片，但后续运行仍然可以命中相同的页面缓存。

远程文件下载有大小和超时限制。ZIP 解压会阻止路径穿越、软链接、文件数量超限和解压体积超限。视觉模型输出写盘前会移除无法验证的图片和链接目标，同时保留可见标签。API Key 不会写入 manifest。

## 安全边界

`doc7` 会以当前用户权限调用 LibreOffice、Chrome 等本地渲染器。处理不可信的 Office、HTML、SVG、EML、MSG、IPYNB 或压缩包时，应使用隔离账号或容器。邮件和 Notebook HTML 会经过清理，远程资源和本地文件引用会被移除，内嵌 BMP/TIFF 会在渲染前转成 PNG。模型 API Key 会作为 Bearer 凭据发送到配置的接口，处理敏感文件前请确认接口地址正确。HTTP 服务默认只监听本机；监听非本机地址时必须使用 Bearer token。服务限制上传大小，为每个任务使用独立目录，并只在配置的保留周期内保存已完成任务。MCP 服务继承宿主进程权限，在共享或不可信环境中应限制可访问的路径和 URL。

## 开源许可证

doc7 采用 [MIT License](./LICENSE) 开源。

运行 `doc7 <command> --help` 查看完整命令。
