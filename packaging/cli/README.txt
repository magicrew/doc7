doc7
====

Turn any document into AI-ready Markdown.

1. Put doc7 (or doc7.exe) on PATH.
2. Start LM Studio or Ollama with a local vision model.
3. Run: doc7 setup
4. Convert: doc7 <file>

macOS note:
  The curl installer is the recommended path because it verifies the release and installs
  under the current user. If you downloaded and extracted this archive in a browser and
  macOS blocks the executable, run this from Terminal after extraction:

  xattr -dr com.apple.quarantine <extracted-directory>

  This clears the local browser quarantine. It is not a Developer ID signature or notarization.

Examples:
  doc7 report.pdf
  doc7 screenshot.png
  doc7 chat "Hello, introduce yourself"
  doc7 chat
  doc7 chat "Turn report.pdf into knowledge-base Markdown"

Chat Agent:
  Ordinary messages go directly to the configured model. When the user supplies
  a document and asks for conversion, models with OpenAI-compatible Tool Calling
  can invoke doc7's restricted convert_document tool. For vague filenames, the
  agent can use structured read-only commands (pwd, ls, find, file, stat, wc,
  realpath) inside authorized directories and ask the user to choose a file.
  It never executes an arbitrary shell string or write command. head and tail
  require confirmation because their limited text preview is visible to the model.
  Use doc7 <file> for direct conversion with any vision model.
  It can also inspect the config path, discover local LM Studio/Ollama models,
  verify vision capability, and propose configuration changes in natural language.
  Changes are dry-run first and require an ask_user confirmation. When a remote
  endpoint needs an API key, input_secret opens a hidden local prompt; only the
  entered length and storage source are returned. Use doc7 setup config
  --api-key-stdin in non-interactive environments.

Configuration:
  doc7 config show
  doc7 config path
  doc7 config set
  doc7 config set language auto

Update:
  doc7 update --check
  doc7 update

Documentation and releases:
  https://github.com/magicrew/doc7
