# Kotlin LSP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers-extended-cc:subagent-driven-development (recommended) or superpowers-extended-cc:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the official JetBrains `kotlin-lsp` (Kotlin/kotlin-lsp) into this LazyVim-based Neovim config as the active LSP for Kotlin files, replacing the older fwcd `kotlin_language_server` brought in by LazyVim's Kotlin extra.

**Architecture:** Enable `lazyvim.plugins.extras.lang.kotlin` for surrounding tooling (treesitter, ktlint via conform/lint, debug adapter), then override the LSP layer in `lua/plugins/lspconfig.lua` to disable the old server (`kotlin_language_server = false`) and add the new one (`kotlin_lsp` with `cmd = { "kotlin-lsp", "--stdio" }`). Server binary installed via Homebrew. Document the brew + JDK 17 prerequisite in the repo README.

**Tech Stack:** Neovim, LazyVim, lazy.nvim, nvim-lspconfig, Homebrew, JDK 17+, JetBrains kotlin-lsp (pre-alpha).

**Spec:** `docs/superpowers/specs/2026-05-06-kotlin-lsp-design.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `lazyvim.json` | Modify | Add `lazyvim.plugins.extras.lang.kotlin` to `extras` array. |
| `lua/plugins/lspconfig.lua` | Modify | Add `servers` table to opts: disable `kotlin_language_server`, add `kotlin_lsp` with `cmd` override. |
| `README.md` | Modify | New section documenting `brew install JetBrains/utils/kotlin-lsp` and JDK 17+ requirement. |

No files created. Three coherent commits.

---

## Task 1: Install Kotlin LSP server via Homebrew

**Goal:** Get `kotlin-lsp` binary on PATH so Neovim can spawn it.

**Files:** None (host shell action only).

**Acceptance Criteria:**
- [ ] `which kotlin-lsp` resolves to a brew-installed path.
- [ ] `kotlin-lsp --version` prints a version string starting with `LS-`.
- [ ] `java -version` reports JDK 17 or higher (the JVM that will be used to run the server).

**Verify:**

```bash
which kotlin-lsp && kotlin-lsp --version && java -version 2>&1 | head -1
```

Expected: a path to `kotlin-lsp`, a `LS-<version>` line, and a Java version line where the major version is `17` or higher.

**Steps:**

- [ ] **Step 1: Verify JDK 17+ is available**

```bash
java -version 2>&1 | head -1
```

If the major version is below 17, install a JDK 17+ first (e.g. `brew install --cask temurin` or `brew install openjdk@21`). Re-check before continuing.

- [ ] **Step 2: Install via Homebrew tap**

```bash
brew install JetBrains/utils/kotlin-lsp
```

Expected: brew taps `JetBrains/utils`, downloads the `kotlin-server-<version>.sit` archive, installs into the brew prefix, and symlinks `kotlin-lsp` into `bin/`.

- [ ] **Step 3: Verify binary is on PATH and runs**

```bash
which kotlin-lsp
kotlin-lsp --version
```

Expected: a non-empty path (typically `/opt/homebrew/bin/kotlin-lsp` on Apple Silicon, `/usr/local/bin/kotlin-lsp` on Intel) and a version string starting with `LS-`.

- [ ] **Step 4: No commit**

This task changes the host environment, not the repo. Move to Task 2.

---

## Task 2: Wire `kotlin_lsp` into the Neovim config

**Goal:** Enable LazyVim's Kotlin extra and override the LSP layer so `kotlin_lsp` attaches to `.kt`/`.kts` buffers (and `kotlin_language_server` does not).

**Files:**
- Modify: `lazyvim.json`
- Modify: `lua/plugins/lspconfig.lua`

**Acceptance Criteria:**
- [ ] `lazyvim.json` contains `"lazyvim.plugins.extras.lang.kotlin"` in its `extras` array.
- [ ] `lua/plugins/lspconfig.lua` sets `servers.kotlin_language_server = false` and `servers.kotlin_lsp = { cmd = { "kotlin-lsp", "--stdio" } }` inside `opts`.
- [ ] Opening a `.kt` file in a Gradle-rooted project causes `kotlin_lsp` to attach (verified with `:LspInfo`).
- [ ] `:LspInfo` does NOT list `kotlin_language_server`.
- [ ] Treesitter highlights are present in `.kt` buffers (`:TSInstallInfo` shows `kotlin` installed).

**Verify:**

Within Neovim, open a `.kt` file inside a Gradle project, then run:

```
:LspInfo
:TSInstallInfo kotlin
```

Expected: `LspInfo` shows `kotlin_lsp` attached and no `kotlin_language_server` entry; `TSInstallInfo` shows the `kotlin` parser installed.

**Steps:**

- [ ] **Step 1: Read current `lazyvim.json`**

```bash
cat lazyvim.json
```

Confirm it currently looks like:

```json
{
  "extras": [
    "lazyvim.plugins.extras.editor.harpoon2",
    "lazyvim.plugins.extras.formatting.prettier",
    "lazyvim.plugins.extras.lang.json",
    "lazyvim.plugins.extras.lang.typescript",
    "lazyvim.plugins.extras.lang.typescript.vtsls"
  ],
  "install_version": 8,
  "news": {
    "NEWS.md": "11866"
  },
  "version": 8
}
```

- [ ] **Step 2: Add the Kotlin extra**

Edit `lazyvim.json`. Append `"lazyvim.plugins.extras.lang.kotlin"` to the `extras` array (alphabetical ordering preserved):

```json
{
  "extras": [
    "lazyvim.plugins.extras.editor.harpoon2",
    "lazyvim.plugins.extras.formatting.prettier",
    "lazyvim.plugins.extras.lang.json",
    "lazyvim.plugins.extras.lang.kotlin",
    "lazyvim.plugins.extras.lang.typescript",
    "lazyvim.plugins.extras.lang.typescript.vtsls"
  ],
  "install_version": 8,
  "news": {
    "NEWS.md": "11866"
  },
  "version": 8
}
```

- [ ] **Step 3: Read current `lua/plugins/lspconfig.lua`**

```bash
cat lua/plugins/lspconfig.lua
```

Confirm it currently looks like:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
}
```

- [ ] **Step 4: Add `servers` override**

Replace the file contents with:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        -- The LazyVim Kotlin extra wires up the older fwcd kotlin-language-server.
        -- We disable it and use the official JetBrains kotlin-lsp instead.
        kotlin_language_server = false,
        kotlin_lsp = {
          cmd = { "kotlin-lsp", "--stdio" },
        },
      },
    },
  },
}
```

- [ ] **Step 5: Sync plugins from the command line**

```bash
nvim --headless "+Lazy! sync" +qa
```

Expected: lazy.nvim installs/updates plugins introduced by the Kotlin extra (treesitter `kotlin` parser, mason `ktlint`, etc.) and exits cleanly.

- [ ] **Step 6: Open a Kotlin file in a Gradle-rooted project and verify LSP attaches**

Pick any local Kotlin project (one containing `build.gradle.kts` or `settings.gradle.kts`). Then run:

```bash
nvim path/to/project/src/main/kotlin/Anything.kt
```

Inside Neovim:

```
:LspInfo
```

Expected: a buffer shows `kotlin_lsp` as an attached client; `kotlin_language_server` is NOT listed. If `kotlin_lsp` is missing, run `:LspLog` to inspect why (most likely cause: `kotlin-lsp` binary not on PATH from Task 1, or JDK < 17).

- [ ] **Step 7: Sanity-check editor features**

Inside the same Neovim session on the `.kt` buffer:

- Place cursor on a stdlib symbol (e.g. `println`) and press `K`. Expected: hover popup with kdoc.
- Press `gd` on a project-defined symbol. Expected: jump to definition.
- Run `:TSInstallInfo kotlin`. Expected: parser is installed.

If hover/goto fail but `kotlin_lsp` is attached, that is most likely a pre-alpha server limitation — note it but do not block the task.

- [ ] **Step 8: Commit**

```bash
git add lazyvim.json lua/plugins/lspconfig.lua
git commit -m "feat(lsp): switch Kotlin LSP to JetBrains kotlin-lsp

Enable LazyVim's Kotlin extra for treesitter/ktlint/dap wiring, then
override the LSP layer to disable the older fwcd kotlin_language_server
and use the official JetBrains kotlin-lsp via brew (cmd: kotlin-lsp --stdio).

Spec: docs/superpowers/specs/2026-05-06-kotlin-lsp-design.md"
```

---

## Task 3: Document prerequisites in README

**Goal:** Tell future-readers (including yourself on a new machine) what to install before this config will give them Kotlin LSP support.

**Files:**
- Modify: `README.md`

**Acceptance Criteria:**
- [ ] `README.md` has a section that names the brew command, the JDK 17+ requirement, and the pre-alpha caveat.
- [ ] The section is reachable from the document structure (either at top-level or under an existing language/setup heading — whatever fits the current README).

**Verify:**

```bash
grep -n "kotlin-lsp" README.md
```

Expected: at least one match showing the brew install line.

**Steps:**

- [ ] **Step 1: Read the current README**

```bash
cat README.md
```

Decide where the new section best fits (most likely a new top-level `## Kotlin LSP` heading near other setup/install notes, or under an existing "Requirements"/"Setup" section if one exists).

- [ ] **Step 2: Add the prerequisites section**

Append (or insert at the chosen location) the following block. Adjust heading level to match the existing document structure.

```markdown
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
```

- [ ] **Step 3: Verify**

```bash
grep -n "kotlin-lsp" README.md
```

Expected: at least one line of output showing the brew install command.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: document Kotlin LSP install (brew + JDK 17+)

Spec: docs/superpowers/specs/2026-05-06-kotlin-lsp-design.md"
```

---

## Self-Review Notes

- **Spec coverage:** Component 1 (enable extra) → Task 2 step 2; Component 2 (override servers) → Task 2 step 4; Component 3 (README) → Task 3. Testing checklist from spec covered by Task 2 steps 6–7. Pre-alpha caveat surfaced in Task 3 step 2.
- **No placeholders:** All file paths, commands, and code blocks are concrete. No "TBD"/"TODO"/"add appropriate X" left in.
- **Type/name consistency:** Server names are spelled `kotlin_language_server` and `kotlin_lsp` everywhere (matching nvim-lspconfig keys). Cmd is `{ "kotlin-lsp", "--stdio" }` everywhere.
