# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Kotlin LSP

This config uses the official JetBrains [`kotlin-lsp`](https://github.com/Kotlin/kotlin-lsp)
as the LSP for Kotlin files.

**Install (macOS):**

```bash
brew install JetBrains/utils/kotlin-lsp
```

**Requirements:**

- JDK 17 or higher on `PATH` (the server runs on the JVM).
- Homebrew (the server is not yet in the Mason registry).

**Caveat:** `kotlin-lsp` is **pre-alpha**. Expect bugs and missing features. The
older `kotlin_language_server` (fwcd) that LazyVim's Kotlin extra wires up by
default is intentionally disabled in `lua/plugins/lspconfig.lua`.
