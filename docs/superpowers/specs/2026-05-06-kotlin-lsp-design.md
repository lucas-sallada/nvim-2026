# Kotlin LSP Integration

**Date:** 2026-05-06
**Status:** Design approved, pending implementation

## Goal

Add the official JetBrains Kotlin Language Server ([Kotlin/kotlin-lsp](https://github.com/Kotlin/kotlin-lsp)) to this LazyVim-based Neovim configuration as the active LSP for Kotlin files, replacing the older community `kotlin_language_server` (fwcd) that LazyVim's Kotlin extra wires up by default.

## Context

- Editor: Neovim with LazyVim distribution.
- Current state: no Kotlin extra enabled, no Kotlin LSP configured.
- `nvim-lspconfig` master ships a default config for `kotlin_lsp` (`lsp/kotlin_lsp.lua`) with `cmd = { "intellij-server", "--stdio" }`.
- The Homebrew formula `JetBrains/utils/kotlin-lsp` installs the server and exposes the binary on PATH as `kotlin-lsp` (symlink to `intellij-server`).
- The server is **pre-alpha**. Expect bugs, missing features, and breaking changes between versions.

## Non-goals

- Replacing `nvim-lspconfig`'s default `kotlin_lsp` server definition. We override only `cmd`.
- Removing the LazyVim Kotlin extra. We enable it for the surrounding tooling (treesitter, ktlint, conform, debug adapter) and only disable its LSP entry.
- Mason-managed install. The server is not in the Mason registry; brew is the recommended path.
- Linux support. The brew formula is macOS-only; Linux users would need the manual zip path, which is out of scope here.

## Architecture

```
Neovim
  └─ nvim-lspconfig
       └─ kotlin_lsp server (config from nvim-lspconfig, cmd overridden)
            └─ spawns: kotlin-lsp --stdio   (brew-installed binary on PATH)
                 └─ JetBrains intellij-server (JVM, JDK 17+)
```

LazyVim's Kotlin extra contributes treesitter parser, ktlint formatter/linter wiring (via conform.nvim and nvim-lint), and a Kotlin debug adapter config. We keep all of that and only swap the LSP entry.

## Components

### 1. Enable the LazyVim Kotlin extra

**File:** `lazyvim.json`

Add `"lazyvim.plugins.extras.lang.kotlin"` to the `extras` array. This pulls in:

- treesitter `kotlin` parser
- `ktlint` (via Mason)
- `kotlin_language_server` (the old fwcd server) — to be disabled in step 2
- conform.nvim and nvim-lint wiring for ktlint
- nvim-dap kotlin adapter config

### 2. Override LSP servers in lspconfig opts

**File:** `lua/plugins/lspconfig.lua`

Extend the existing override:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        kotlin_language_server = false,
        kotlin_lsp = {
          cmd = { "kotlin-lsp", "--stdio" },
        },
      },
    },
  },
}
```

Notes:
- LazyVim treats a server entry of `false` as "do not setup" — this neutralizes the entry the Kotlin extra adds.
- We override `cmd` because brew installs the binary as `kotlin-lsp`, while `nvim-lspconfig`'s default config calls `intellij-server`. We do not redefine the rest of the config (filetypes, root_markers); those come from `nvim-lspconfig`.

### 3. Document prerequisites

**File:** `README.md`

Append a short section noting:
- `brew install JetBrains/utils/kotlin-lsp` is required for Kotlin LSP support.
- JDK 17 or higher must be available to the JVM the server launches.
- Server is pre-alpha; instability is expected.

## Data flow

1. User opens a `.kt` or `.kts` file.
2. LazyVim/lspconfig matches filetype `kotlin` to `kotlin_lsp` server config.
3. lspconfig walks parent dirs looking for one of: `settings.gradle(.kts)`, `pom.xml`, `build.gradle(.kts)`, `workspace.json`. First match becomes project root.
4. lspconfig spawns `kotlin-lsp --stdio` rooted at that directory.
5. JSON-RPC over stdio between Neovim and the server. Pull-based diagnostics (Neovim 0.10+ handles natively).

## Error handling and edge cases

| Failure | Symptom | Resolution |
|---------|---------|------------|
| `kotlin-lsp` not on PATH | lspconfig logs "cmd not executable" or no LSP attaches | User runs `brew install JetBrains/utils/kotlin-lsp`. Documented in README. |
| JDK < 17 | Server starts then exits; logs show JVM version error | README notes JDK 17+ requirement. |
| Project has no recognized root marker | lspconfig falls back to single-file mode or doesn't attach | Acceptable for pre-alpha; unchanged from default. |
| LazyVim Kotlin extra not enabled but `kotlin_lsp` configured | Server still attaches; treesitter/formatter/lint missing | Step 1 enables the extra to prevent this. |
| Pre-alpha server crash | LSP detaches; user sees broken completions | Out of scope; track upstream issues. |

## Testing

Manual verification after install:

1. Open a `.kt` file inside a Gradle project (e.g., one with `build.gradle.kts`).
2. Run `:LspInfo` (or `:checkhealth lsp`):
   - `kotlin_lsp` is listed as attached.
   - `kotlin_language_server` is NOT listed.
3. Hover (`K`) on a stdlib symbol — kdoc renders.
4. Goto definition (`gd`) on a project symbol — jumps correctly.
5. `:TSInstallInfo` — `kotlin` parser installed.
6. `:Mason` — `ktlint` listed as installed.
7. Make a formatting violation, save → conform.nvim runs ktlint and reformats (or shows diagnostic via nvim-lint).

## Out-of-scope follow-ups

- Pinning a specific server version (would require manual zip install, not brew).
- Linux installation path.
- Replacing `nvim-lspconfig`'s default `kotlin_lsp` config wholesale.
- Migrating to a Mason-based install once the server lands in the registry.
