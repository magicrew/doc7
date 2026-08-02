<div align="center">
  <h1>doc7</h1>
  <p><strong>Any document in. AI-ready Markdown out.</strong></p>
  <p>Turn PDFs, Office files, scans, screenshots, charts, formulas, and diagrams into Markdown your AI can search, quote, and reason over.</p>
  <p><a href="./README.zh-CN.md">简体中文</a> · English</p>
  <p><a href="https://github.com/magicrew/doc7">GitHub</a> · <a href="https://github.com/magicrew/doc7/releases">Releases</a> · <a href="./benchmarks/attention-is-all-you-need/README.md">Benchmark</a></p>
</div>

[![Build](https://github.com/magicrew/doc7/actions/workflows/build.yml/badge.svg)](https://github.com/magicrew/doc7/actions/workflows/build.yml) [![Latest Release](https://img.shields.io/github/v/release/magicrew/doc7?display_name=tag)](https://github.com/magicrew/doc7/releases) [![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

[![doc7 turns any document into AI-ready Markdown](./assets/readme/hero/hero.webp)](#quick-start)

`doc7` turns PDFs, Office files, scans, screenshots, charts, formulas, and
diagrams into Markdown through your own OpenAI-compatible multimodal model.
No required OCR stack. No document-processing service lock-in.

## Quick Start

**Download:** [macOS, Linux, and Windows CLI archives](https://github.com/magicrew/doc7/releases)

Install the latest release without administrator privileges.

macOS or Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/magicrew/doc7/main/scripts/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/magicrew/doc7/main/scripts/install.ps1 | iex
```

The installer is the recommended macOS path. It downloads a checksum-verified
release and installs it under your user directory, so it does not require an
administrator account or an Apple Developer ID. Directly opening a binary
downloaded by a browser is different: macOS may attach a quarantine attribute
to that file. If you choose the archive path, run the included command from
Terminal after extracting it:

```bash
xattr -dr com.apple.quarantine <extracted-directory>
```

This removes the local download quarantine; it is not Apple signing or
notarization. Official Developer ID signing and notarization require an Apple
Developer Program account and are planned for a future signed release channel.

Start LM Studio or Ollama, load a local vision model, and convert a file:

```bash
doc7 report.pdf
doc7 screenshot.png
```

That is the complete first-run flow. doc7 detects the system language, finds
running local model servers, reads their real model IDs, lets you choose when
several models are available, verifies image understanding, and saves the
choice on this machine. LM Studio and Ollama endpoints without authentication
need no API key.

`chat` is a small agent running on the configured local model. Ordinary messages
go directly to the model and do not need a document. Run it without a message for
an interactive session:

```bash
doc7 chat "Hello, introduce yourself"
doc7 chat
```

When the user explicitly supplies a file, directory, or URL and asks doc7 to
process it, the model can call the restricted `convert_document` tool:

```bash
doc7 chat "Turn report.pdf into knowledge-base Markdown"
```

There is no keyword or language-specific intent parser. The model decides whether
to use tools through OpenAI-compatible Tool Calling. For a vague filename, Chat can
use a structured read-only filesystem tool set (`pwd`, `ls`, `find`, `file`, `stat`,
`wc`, and `realpath`) inside authorized directories, then ask you to choose a
candidate before conversion. It never receives an arbitrary shell string: there are
no pipes, redirects, scripts, writes, network commands, or process controls.

The session starts with the working directory and existing Desktop, Documents, and
Downloads directories. Other directories require an explicit path entered in the
local terminal. `head` and `tail` are separate preview tools because they expose
limited text content to the model; Chat asks for confirmation before using them.
Models without Tool Calling can still chat; use `doc7 <file>` as the stable direct
conversion entrypoint.

The same chat agent can guide first-time configuration in natural language. It can
show the effective config path, discover models exposed by local LM Studio or Ollama,
and verify a candidate with a real vision probe:

```text
doc7> Use the local LM Studio model that can understand images
doc7> Switch the interface to English
doc7> Check whether my current model configuration works
```

Configuration changes are dry-run first. The agent calls `ask_user` to show a clear
choice, and only writes the file after the user selects confirmation. Use
`doc7 --yes chat "..."` for explicit one-shot authorization of non-secret changes.
When a remote endpoint needs an API key, Chat can start a hidden local input prompt;
the model may see the number of entered bytes and the credential source, but never
the key content. In non-interactive environments, use `doc7 setup config --api-key-stdin`.

Inspect or change the local configuration:

```bash
doc7 config show
doc7 config path
doc7 config set              # list editable keys, current values, and descriptions
doc7 config set language en       # en, zh-CN, or auto
doc7 setup                        # run local model discovery again
```

`doc7 config` prints the effective configuration file path. Localized labels keep
their stable English keys beside them, so values can be edited without guessing:

```bash
doc7 config set model <model-id>
doc7 config set base_url http://127.0.0.1:1234/v1
doc7 config set credential_store env
```

The usual location is the user configuration directory under `doc7/config.yaml`.
If `.doc7.yaml` exists in the current directory or one of its parents, doc7 shows
and uses that effective path instead. Use `--config <path>` to select a file
explicitly.

Update an installed CLI:

```bash
doc7 update --check
doc7 update
```

The updater reads the latest stable GitHub Release, downloads the matching package
for the current platform, and verifies `checksums.txt`. On Windows, replacement is
deferred until the running executable exits; the install directory must be writable
by the current user.

Remote OpenAI-compatible endpoints are supported too. Before the first remote
conversion, doc7 clearly warns that document content will leave the machine.
API keys stay in the system keychain, Windows Credential Manager, an explicitly
selected environment variable, or a local credential file. They are never
stored in this repository or a release archive.

The Windows x86_64 archive contains the CLI and launchers. Windows Portable
packages additionally bundle the document renderers, so they can be extracted
to a short path such as `C:\doc7` on machines where software installation is
restricted. The model always runs at the endpoint you configure; it is not
embedded in the CLI archive.

## Your Local Model, Near-Zero Marginal Cost

doc7 does not sell document credits and does not charge per page, image, or
conversion. Run a quantized multimodal model on your own laptop, workstation,
server, or private inference machine, and process as many documents as that
hardware can handle. When the hardware already exists, the marginal cost of
another document approaches the electricity and operating time it consumes.

- **No document API meter.** Repeated and large-batch conversion does not create
  a new doc7 bill for every page.
- **Use hardware you already own.** Quantized open models turn available CPU,
  GPU, and unified memory into a reusable document-processing endpoint.
- **One model, many document types.** The same endpoint can understand text,
  tables, formulas, charts, diagrams, screenshots, and image meaning without a
  separate OCR, layout, table, and formula-model stack.
- **Keep documents private.** A local or private endpoint keeps document content
  inside infrastructure you control.

Small quantized vision models can run on modest machines when their memory
requirements fit. Quality, speed, and minimum hardware depend on the model and
quantization you choose; doc7 does not prescribe a model size or claim that all
models produce the same result.

## Local Inference vs Cloud Document APIs

Cloud pricing changes by region, model, feature, and volume. The durable
difference is the cost structure: cloud document APIs meter pages, images, or
feature calls; local doc7 inference mainly uses hardware and electricity you
control.

| Option | Typical billing unit | Cost as document volume grows | Document location |
| --- | --- | --- | --- |
| **doc7 + local quantized VLM** | No doc7 per-page or per-call fee | Mostly existing hardware, electricity, and operations | Local or private infrastructure |
| [AWS Textract](https://aws.amazon.com/textract/pricing/) | Pages, priced by API and analysis feature | Usage grows with pages and enabled features | Cloud API |
| [Google Document AI](https://cloud.google.com/products/document-ai/pricing) | Pages, usually priced per processor and volume tier | Usage grows with pages and processor type | Cloud API |
| [Azure Document Intelligence](https://azure.microsoft.com/en-us/pricing/details/document-intelligence/) | Pages, model, and pricing tier | Usage grows with pages and selected capability | Cloud API |
| [Alibaba Cloud OCR](https://help.aliyun.com/zh/ocr/product-overview/product-billing/) | Pay-as-you-go calls or prepaid resource packages | Continued processing consumes calls or package quota | Cloud API |
| [Tencent Cloud OCR](https://buy.cloud.tencent.com/price/ocr) | API calls through prepaid or postpaid billing | Continued processing consumes calls or package quota | Cloud API |
| [Baidu AI Cloud OCR](https://cloud.baidu.com/doc/OCR/s/Jk3h7xtsd) | API calls, free quota, and paid usage | Continued processing consumes calls or quota | Cloud API |

Cloud APIs remain useful when teams want managed capacity and do not want to
operate a model. doc7 is designed for the opposite case: reuse a local or
private model, eliminate a recurring document-parser bill, and turn long-term
document conversion into infrastructure you own.

## High-Complexity Papers, Precise Markdown

[![doc7 turns Attention Is All You Need into AI-ready Markdown](./examples/attention-is-all-you-need/showcase.webp)](./examples/attention-is-all-you-need/input.webp)

One raster-only page from *Attention Is All You Need*. No text layer. doc7
recovers the paper identity, Figure 2, the displayed equation, the scaling
rationale, the technical footnote, and the ordered relationships inside both
attention diagrams as searchable Markdown.

The same pipeline processes complete papers and multi-page reports, then
rebuilds the ordered pages into one document.

`doc7` reads the whole page instead of stopping at character extraction. Bring any OpenAI-compatible multimodal model, including a private or local deployment. There is no required OCR stack and no per-page document-parser fee from doc7.

## Open Benchmark

[![doc7 Visual Understanding Benchmark](./assets/readme/benchmark/benchmark.webp)](./benchmarks/visual-report/README.md)

Two raster-only PDFs. Fifteen machine-checkable visual facts. MarkItDown OCR
and doc7 used the same `qwen3.5-9b` model through the same local
OpenAI-compatible endpoint. Docling used its standard local pipeline.

| System | Attention paper | Visual report | Combined | Raw Markdown |
| --- | ---: | ---: | ---: | ---: |
| **#1 doc7 + qwen3.5-9b** | **7/7** | **8/8** | **15/15** | **5,293 bytes** |
| MarkItDown 0.1.6 + OCR 0.1.0 + qwen3.5-9b | 3/7 | 6/8 | 9/15 | 13,142 bytes |
| Docling 2.113.0 standard | 1/7 | 2/8 | 3/15 | 2,571,445 bytes |
| MarkItDown 0.1.6 default | N/A | N/A | N/A | 0 bytes |

The paper case checks identity, Figure 2, both ordered attention flows, the
displayed equation, the scaling rationale, and the technical footnote. The
visual-report case checks text, KPI cards, chart data and trend, a table,
formula semantics and LaTeX, workflow order, and UI state.

MarkItDown's default path returned an empty file for both raster-only inputs, so
it is reported as `N/A`, not assigned a misleading zero capability score. Its
official OCR plugin is scored separately. Docling's raw Markdown is large
because it embeds page images as Base64; byte count is diagnostic, not a quality
score.

[Attention input](./examples/attention-is-all-you-need/input.pdf) · [doc7 output](./examples/attention-is-all-you-need/output.md) · [Attention benchmark](./benchmarks/attention-is-all-you-need/README.md) · [Visual-report benchmark](./benchmarks/visual-report/README.md)

Run metadata: `2026-07-30` · `darwin/arm64`. Every raw output, SHA-256 digest,
scoring rule, and machine-readable result is committed for inspection. No model
endpoint or credential is included.

These are focused visual-understanding cases, not a universal product ranking.
The paper input is an attributed scholarly benchmark composition derived from
page 4 of *Attention Is All You Need* and is excluded from doc7's MIT license.
[Read the source and permission record](./examples/attention-is-all-you-need/source.json).

For a pinned large-scale evaluation, use the [olmOCR-Bench adapter](./benchmarks/olmocr/README.md). It supports the upstream 1,403-PDF / 7,010-fact suite without redistributing its third-party documents; doc7 does not claim a full-suite ranking until a complete pinned run is published.

## One Pipeline, Every Document

[![doc7 processes every document through one visual-understanding pipeline](./assets/readme/formats/formats.webp)](#supported-inputs)

Different containers enter the same page-understanding pipeline. Text,
tables, formulas, charts, diagram relationships, image meaning, and visible UI
state leave as one searchable Markdown document.

## A Different Architecture

| Primary approach | Representative projects | What happens | What you operate |
| --- | --- | --- | --- |
| Format and text extraction | [MarkItDown](https://github.com/microsoft/markitdown) default path | File-specific parsers recover text and basic structure | Python packages and optional plugins |
| Vision-model OCR wrapper | [Zerox](https://github.com/getomni-ai/zerox) | Pages become images and are sent to a provider-specific vision SDK | Node/Python SDKs, GraphicsMagick/Ghostscript, and provider credentials |
| Dedicated document AI stack | [MinerU](https://github.com/opendatalab/MinerU), [Docling](https://github.com/docling-project/docling) | OCR, layout, table, formula, and document models work as a pipeline | Model weights, runtimes, and document-specific infrastructure |
| Full-page visual understanding | **doc7** | Pages are rendered and reconstructed by your multimodal model | A cross-platform CLI, Go SDK, MCP tool, asynchronous HTTP service, and your existing model endpoint |

The model remains your choice. `doc7` does not prescribe a model size or claim quality that has not been measured. With a private open model, there is no required external document-processing service and no doc7 usage quota.

## The CLI Is The Product

[![doc7 command-line interface on macOS, Linux, and Windows](./assets/readme/cli/cli.webp)](#quick-start)

The same binary provides the interactive CLI, batch processing, model checks,
MCP, the Go SDK, and the asynchronous HTTP service.

## Model, Dependency, and Recovery Workflow

Discover the model IDs exposed by an OpenAI-compatible vision endpoint:

```bash
doc7 models --base-url http://localhost:8000/v1
```

LM Studio uses `http://127.0.0.1:1234/v1` by default. Start its local server,
then use that URL and one of the model IDs it returns.

Save the endpoint and one returned model ID:

```bash
doc7 setup config \
  --base-url http://localhost:8000/v1 \
  --model <model-id>
```

Authenticated endpoints can use `DOC7_API_KEY` or `doc7 setup config --api-key-stdin`. To use another environment variable, set it explicitly with `--api-key-env`, for example `--api-key-env OPENAI_API_KEY`. doc7 never scans provider-specific environment variables automatically, and endpoints without authentication need no placeholder key; doc7 omits the `Authorization` header.

Check local dependencies and send a real, tiny image request to the model:

```bash
doc7 doctor --check-model
```

Pass the document you are about to process to make format-specific dependencies strict:

```bash
doc7 doctor report.docx --check-model
```

Read a document:

```bash
doc7 read report.pdf -o report-doc7
```

Reprocess only selected source pages when a page needs another model or
settings. Page numbers are 1-based, ranges are inclusive, and the original
page numbers remain in the output and manifest:

```bash
doc7 read report.pdf -o report-pages-5-7 --pages 5,7
doc7 read report.pdf -o report-pages-10-12 --pages 10-12
```

The manifest records both `source_page_count` and `page_selection`; selected
pages are still written as `page_005.md`, `page_007.md`, and so on. Artifact
paths in manifests and page metadata are relative to the output directory, so
the complete result can be moved or unpacked on another machine.

If a long document finishes with only a few failed pages, retry the existing
output instead of starting over:

```bash
doc7 read report.pdf -o report-doc7 --resume
doc7 read report.pdf -o report-doc7 --resume --pages 5,7
```

Without `--pages`, doc7 automatically selects every failed page in the existing
manifest. An explicit selection must contain failed pages only, and the input
SHA-256 must still match. Successful pages remain byte-for-byte unchanged. The
previous manifest is archived under `history/`; the new manifest records
processed and retained page counts plus per-page model provenance, including a
mixed-model run. If no failed pages remain, `--resume` validates the page
artifacts and rebuilds missing merged Markdown without calling the model.

Or pipe the merged Markdown directly into another tool:

```bash
doc7 read report.pdf --stdout > report.md
```

Read binary input from stdin by supplying its logical filename and extension:

```bash
cat report.pdf | doc7 read - --stdin-name report.pdf --stdout > report.md
```

Stdin input is limited to 1,024 MB by default. Use `--stdin-max-mb` to change the limit.

Read a directory recursively:

```bash
doc7 read ./documents -o ./knowledge
```

For large directories, `--file-workers` controls how many documents are processed at once and `--workers` controls page requests inside each document. File-level concurrency defaults to `1`; increase it only when the renderer and model endpoint can handle the combined load.

Read a remote document directly:

```bash
doc7 read https://example.com/report.pdf -o ./report-doc7
```

## Run As A Service

Start the local asynchronous HTTP service:

```bash
doc7 serve --addr 127.0.0.1:8787 --data-dir ./doc7-server
```

Submit one local document or ZIP archive:

```bash
curl -F file=@report.pdf http://127.0.0.1:8787/v1/jobs
```

The HTTP service accepts the same page selection as a multipart field:

```bash
curl -F file=@report.pdf -F pages=5,7 http://127.0.0.1:8787/v1/jobs
```

The response contains a job ID. Poll the returned status URL, then download
the merged Markdown or the complete artifact ZIP:

```bash
curl http://127.0.0.1:8787/v1/jobs/<job-id>
curl -o report.md http://127.0.0.1:8787/v1/jobs/<job-id>/markdown
curl -o report-artifacts.zip http://127.0.0.1:8787/v1/jobs/<job-id>/artifacts
```

Retry every failed page, or an explicit failed-page subset, in the same job:

```bash
curl -X POST -H 'Content-Type: application/json' \
  -d '{}' http://127.0.0.1:8787/v1/jobs/<job-id>/resume

curl -X POST -H 'Content-Type: application/json' \
  -d '{"pages":"5,7"}' http://127.0.0.1:8787/v1/jobs/<job-id>/resume
```

Resume uses the server's current model configuration. You can stop the service,
change the model, and restart it with the same `--data-dir` before resuming the
job. Invalid selections return `409 resume_rejected` before the job is changed.

`GET /healthz` is unauthenticated. Bind beyond localhost only with a bearer
token, supplied through the environment variable named by
`--auth-token-env` (default: `DOC7_SERVER_TOKEN`):

```bash
DOC7_SERVER_TOKEN='replace-me' doc7 serve --addr 0.0.0.0:8787
curl -H 'Authorization: Bearer replace-me' http://127.0.0.1:8787/v1/jobs
```

The service accepts uploaded files and ZIP archives. For URL sources, use the
CLI or the Go `Read` API, where the caller controls the network policy.

## Use From AI Tools

doc7 includes an MCP server with a typed `convert_to_markdown` tool. Configure
your MCP client to launch the binary over stdio:

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

The tool accepts a local path, directory, HTTP(S) URL, or ZIP archive and
returns Markdown plus structured conversion metadata. Automatically created
artifacts are kept under the user cache directory; override it with
`doc7 mcp --output-root <path>`. To retry failed pages in a persistent output,
pass the same `input` and `output_dir` with `resume: true`; `pages` may restrict
the retry to a failed-page subset.

## Run With Docker

The Docker image includes LibreOffice, MuPDF, Chromium, and CJK fonts. It runs
the HTTP service as a non-root user and persists configuration and jobs in
named volumes:

```bash
export DOC7_MODEL=qwen3.5-0.8b
export DOC7_SERVER_TOKEN=replace-me
docker compose pull
docker compose up --no-build
```

The published image is `ghcr.io/magicrew/doc7:latest` and contains both
`linux/amd64` and `linux/arm64`. Use `docker compose up --build` when you want
to build the current source locally instead.

The default model endpoint is `http://host.docker.internal:1234/v1`, which
works for LM Studio on Docker Desktop. Set `DOC7_BASE_URL` for another
endpoint. Submit files to `http://127.0.0.1:8787/v1/jobs` after the container
health check is ready.

If the build environment requires a proxy, do not pass the host's
`127.0.0.1` proxy address into Docker Desktop. Use the host address visible
from the container instead:

```bash
export DOC7_BUILD_HTTP_PROXY=http://host.docker.internal:7890
export DOC7_BUILD_HTTPS_PROXY=http://host.docker.internal:7890
docker compose up --build
```

Use a domain-specific conversion prompt without modifying doc7:

```bash
doc7 read ./reports --prompt-file ./prompt.md
```

For PDF and Office files that contain an embedded text layer, enable an
optional exact-value check:

```bash
doc7 read report.pdf --text-grounding
```

The page image remains the primary source. doc7 does not run OCR or replace
the visual result with extracted text. It checks exact numbers, codes, and
document identifiers from the embedded text layer, asks the visual model to
confirm candidate corrections, and otherwise preserves the first-pass Markdown
with a `grounding_warnings` count and page-level details. This mode may make
additional model requests and is off by default.

Model requests use `temperature: 0` for repeatable transcription. Each page is
capped at 8,192 output tokens by default. If the provider rejects a request
because the prompt and image exceed its context window, or stops generation
before the configured output limit for the same reason, doc7 automatically
retries with a lower-resolution request image. The original rendered page is
kept for artifacts and grounding. The default allows two fallbacks down to a
720-pixel longest side; configure them with `--context-fallbacks`,
`--min-image-dimension`, `DOC7_CONTEXT_FALLBACKS`, or
`DOC7_MIN_IMAGE_DIMENSION`.

If the model reaches the configured `--max-tokens` value, or all context
fallbacks are exhausted, doc7 marks the page as failed instead of silently
writing truncated Markdown. Page metadata records
`request_image_max_dimension` and `context_fallbacks_used` whenever a fallback
succeeds. Raising `--max-tokens` alone cannot exceed the provider's context
window.

## Embed In Go

The public `github.com/magicrew/doc7` package exposes the same conversion engine
without requiring consumers to import `internal` packages. Use `Read` when the
source may be a local file, directory, HTTP(S) URL, or ZIP archive:

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

`Read` returns either a typed document result or a recursive batch result. When
page selection is used, summaries expose both the selected `PagesTotal` and the
source document's `SourcePagesTotal`. Set `Resume` on `ReadOptions`, `Options`,
or `BatchOptions` to retry existing failed pages; `Pages` may restrict the retry
to a failed-page subset. Use `Convert` and `ConvertBatch` when you want explicit
single-document or directory-only APIs:

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

All three entry points expose typed summaries and progress callbacks; page and
file events may arrive concurrently when concurrency is enabled.

## What Survives The Conversion

| Information on the page | Markdown result |
| --- | --- |
| Headings, paragraphs, lists, quotes, and code | Native Markdown structure |
| Tables and spreadsheets | Markdown or HTML tables with values and units |
| Mathematical notation | Inline or display LaTeX |
| Charts | Labels, values, trends, and conclusions as searchable text |
| Diagrams and workflows | Nodes, ordering, grouping, and relationships |
| Screenshots and application states | Visible status, errors, controls, and actions |
| Email messages | Headers, HTML or text bodies, inline images, and attachment inventory |
| Jupyter notebooks | Markdown cells, source code, execution counts, text output, tracebacks, and visual output |
| Meaningful layout | Comparison, hierarchy, sequence, and spatial relationships |

## Supported Inputs

| Category | Formats |
| --- | --- |
| Documents | PDF, DOC/DOCX/DOCM, DOT/DOTX/DOTM, ODT, RTF |
| Presentations | PPT/PPTX/PPTM, POT/POTX/POTM, PPS/PPSX/PPSM, ODP |
| Spreadsheets | XLS/XLSX/XLSM, XLT/XLTX/XLTM, ODS |
| E-books | EPUB |
| Email and web archives | EML, MHTML/MHT, Outlook MSG |
| Notebooks | Jupyter Notebook (IPYNB) |
| Images | PNG, JPEG, GIF, WebP, BMP, TIFF (including multi-page TIFF), SVG, ordered image directories |
| Native text and data | Markdown, TXT, CSV, TSV, JSON, XML, YAML |
| Web and packages | HTML, HTTP/HTTPS URLs, ZIP archives, nested document directories |

Office and OpenDocument files require LibreOffice. PDF rendering uses MuPDF when available, with platform-specific alternatives reported by `doc7 doctor`. HTML, SVG, EPUB, EML, MHTML/MHT, MSG, and IPYNB rendering require Chrome, Chromium, or Edge. Windows release archives include drag-and-drop batch files.

EML, MHTML/MHT, and Outlook MSG are parsed natively; Microsoft Outlook is not required.

Native text and data formats are converted locally and do not require a VLM. Visual formats, including email messages and Jupyter notebooks rendered as pages, use the configured OpenAI-compatible multimodal endpoint.

## Output Built For AI

Each run keeps the merged Markdown together with page-level Markdown, rendered page images, metadata, and a manifest. That makes the result useful for:

- RAG ingestion and semantic search;
- agent knowledge bases;
- research and document analysis;
- searchable archives of visual reports and screenshots;
- auditable pipelines that need page-level provenance.

Use `--keep-images=false` when only Markdown and metadata are needed. The
rendered images are removed from the completed output, and the same cache still
works on later runs.

Remote files are downloaded with size and timeout limits. ZIP archives are expanded with traversal, symlink, file-count, and expanded-size protections. Visual-model output is normalized before writing: unverifiable image and link targets are removed while their visible labels remain. API keys remain optional and are never written into manifests.

## Security

`doc7` runs local renderers such as LibreOffice and Chrome with the current user's permissions. Treat untrusted Office files, HTML, SVG, EML or MSG messages, IPYNB notebooks, and archive contents as active input, and use an isolated account or container for untrusted workloads. Email and notebook HTML is sanitized, remote resources and local-file references are removed, and embedded BMP/TIFF images are normalized before rendering. Model API keys are sent as bearer credentials to the configured endpoint; verify the endpoint before processing sensitive files. The HTTP service defaults to localhost, requires a bearer token for non-local bind addresses, limits upload size, isolates each job directory, and retains completed jobs only for the configured retention period. The MCP server runs with the privileges of its host process; restrict exposed paths and URL access in shared or untrusted environments.

## License

doc7 is released under the [MIT License](./LICENSE).

Run `doc7 <command> --help` for the complete CLI surface.
