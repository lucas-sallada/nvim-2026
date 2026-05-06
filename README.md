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

**macOS gotchas:**

- If launching Neovim from a GUI launcher (Finder, Dock, app switcher), make
  sure `/opt/homebrew/bin` (Apple Silicon) or `/usr/local/bin` (Intel) is on
  `PATH`. GUI processes inherit a stripped login `PATH` that may exclude brew
  prefixes — symptom: `kotlin_lsp` silently fails to attach. Launching from a
  terminal that loads your shell rc avoids this.
- With multiple JDKs installed, the JVM the server uses is the first `java` on
  `PATH`. If `java -version` shows < 17, set `JAVA_HOME` in your shell rc, e.g.
  `export JAVA_HOME="$(/usr/libexec/java_home -v 21)"`.

**Caveat:** `kotlin-lsp` is **pre-alpha**. Expect bugs and missing features. The
older `kotlin_language_server` (fwcd) that LazyVim's Kotlin extra wires up by
default is intentionally disabled in `lua/plugins/lspconfig.lua`.
