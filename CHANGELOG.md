# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### ⚠ BREAKING CHANGES

- **Palette JSON keys changed to direct semantic names.** The `nvim-colors.json`
  palette no longer uses the `workbench.colorCustomizations` wrapper. Colors are
  keyed directly by semantic names (`surface`, `on_surface`, `primary`, etc.).
- **Removed all JSONC support.** The `lua/matugen/jsonc.lua` module has been
  deleted. Palette files must now be plain `.json`. Update any `.jsonc` palette
  files by removing comments.
- **`jsonc_path` renamed to `palette_path`.** Update your config:
  `require("matugen").setup({ palette_path = "..." })`.
- **Removed `:MatugenStatus` command.** Use `:checkhealth matugen` instead.

### Added

- **Per-mode cursor theming** via `guicursor`. The block cursor uses `primary`
  for normal/command/visual modes, `tertiary` for insert and operator-pending,
  `secondary` for visual selections, and `error` for replace mode. Defined in
  `lua/matugen/templates/editor.lua`.
- **Template system** with split modules for individual plugins organized under
  `lua/matugen/templates/`: nvim-cmp, neo-tree, nvim-tree, oil.nvim, mini.nvim,
  dropbar.nvim, barbecue.nvim, aerial.nvim, zen-mode, twilight, diffview,
  lazygit, fzf-lua, avante.nvim, render-markdown, todo-comments, flash.nvim,
  dressing.nvim, and indent-blankline.
- **Palette validator** (`lua/matugen/validator.lua`). Colors are validated
  before loading the theme. Invalid hex values or missing keys fall back to
  `fallback_palette` instead of crashing.
- **Support for `#RGBA` (4-hex-digit) color format** in the validator and
  `hex()` normalizer.
- **`:checkhealth` integration** for diagnostic checks.
- **SIGUSR1 signal debouncing** to prevent rapid flicker on reload.
- **Template function caching** across reloads for better performance.
- **Dual sync/async loading** with recursion guard via caching bypass.
- **Trailing-edge debounce** for SIGUSR1 signal and reload notifications.
- **Generation counter** to discard stale async palette reads.
- **Robust fallback color scheme** with graceful degradation on load failure.
- **`nvim-colors.json`** bundled in the repository (moved from GitHub Gist).
- **Test suite** with initial specs for setup and error handling
  (`tests/matugen_spec.lua`, `tests/minimal_init.lua`).
- **GitHub Actions CI** (`.github/workflows/tests.yml`) running tests on
  pushes/PRs to `main`.
- **`.github/Makefile`** with `test` target for local headless test execution.
- **Lua syntax validation and luacheck** in CI pipeline.
- **Plenary.nvim-based validator test suite.**
- **`.luarc.json`** with proper LSP settings for local development.
- **AGENTS.md** with commit discipline and conventional commits rules.
- **opencode configuration** with commit-on-each-step instructions.

### Fixed

- **Terminal cursor color no longer falls back to default.** Neovim now uses
  the real host-terminal cursor in Terminal mode instead of a virtual one
  (neovim/neovim#31562), and the default `guicursor` maps Terminal mode to the
  `TermCursor` highlight group via a `t:` entry. Added
  `t:block-TermCursor` to the `guicursor` string in `setup()` so matugen's
  `TermCursor` color is applied. Removed the now-dead `TermCursorNC` highlight
  definition. `termguicolors` is also enabled in `setup()` since cursor color
  (not shape) requires it.
- **Security:** Template loading pinned to plugin's own directory.
- **Security:** Palette path anonymized in globals; status leak dropped.
- **Security:** `jsonc_path` extension validated and path reused expanded.
- **Security:** `opts` validated in `setup()` with defaults.
- JSONC line comments at byte 0 of a file are now correctly stripped.
- Broken regex in `is_valid_hex` replaced with explicit length checks.
- Non-hex color values no longer cause false validation failures.
- Deduplicated invalid-palette warning on cache replay (shown once per
  session instead of on every signal reload).
- Loop variable renamed to avoid shadowing Lua's global `type()`.
- Removed spurious warning when `load_theme` is set to `false`.
- Removed unrelated `winblend` autocmd from `plugin/matugen.lua`.
- Always re-apply all template highlights on reload (removed incremental
  `hlID` guard that could miss groups removed by other plugins).
- Duplicate `Normal` highlight definition removed.
- Templates re-applied on Mason `FileType` event.
- Template cache cleared on manual `:MatugenReload`.
- Recursion guard replaced with caching bypass to prevent double load.
- Safer JSONC comment stripping to avoid clobbering string values.
- `load_theme()` used in reload paths; double-require removed.
- `prevent crash when jsonc_path is nil`.
- Deferred reload notification until theme is actually applied.
- Floating window backgrounds made opaque.

### Changed

- **Major refactor:** Palette logic moved to `lua/matugen/palette.lua` with
  decoupled architecture. Template placeholders changed from `.hex` suffix
  to direct color variable names.
- **`nvim-template.jsonc`** renamed to `nvim-colors.jsonc`, then migrated to
  `nvim-colors.json` (plain JSON).
- **README rewritten** for decoupled architecture and cross-editor color
  parity, with supported plugins section, collapsible plugin list, and demo
  video links.
- **Validator moved from `tests/` to `lua/matugen/`**, replacing `dofile`-based
  loading with standard `require`.
- **Extracted JSONC comment stripper** into `lua/matugen/jsonc.lua` — shared
  by `init.lua` and `health.lua`.
- **Hoisted `hex()`** from inside `_apply_highlights` to module level.
- **Added `---@param` / `---@return` type annotations** to public API.
- **Moved hex validation** from `palette.lua` to `validator.lua`.
- **Moved required-keys list** from `palette.lua` to `validator.lua`.
- **Moved fallback logic** from `palette.lua` to `init.lua`.
- **Bypass palette.lua entirely** when validator rejects raw palette values.
- **Template loading switched from `vim.fn.glob` to `vim.fn.resolve`** for
  better performance, later to `vim.fs.dir`.
- **Removed per-file `vim.fn.resolve` calls** by resolving template dir once.
- **Deduplicated `fallback_palette` merge** into a single post-resolution step.
- **Removed unused `vim.g` writes** that triggered global `OptionSet` events.
- **Reduced SIGUSR1 debounce** from 300ms → 100ms → 50ms, then removed the
  single-fire debounce timer entirely in favor of trailing-edge debounce.
- **Plugin config now provides opts** via `vim.g.matugen_opts` instead of
  hardcoded defaults.
- **`lazygit` template renamed** to `TUI_theme.lua`.
- **Template descriptions and redundant `ui.lua` wrapper** removed.
- **`ui.lua` updated** to use split modules for individual plugin templates.
- **Indentation of `nvim-colors.json`** changed to 2 spaces.
- **`.github/` directory restructured** — Makefile and check-syntax script
  moved into `.github/`.
- **Plenary.nvim dependency removed**; test workflow and trivial test
  directory cleaned up.
- **Doc files updated** to match current codebase.

### Docs

- README updated with cross-editor color parity, supported plugins,
  contributing section, demo video, and proper lazy.nvim configuration.
- Help file (`doc/matugen.txt`) updated with API documentation, template
  caching behavior, reload behavior, and example configuration.
- Various typo fixes and formatting improvements across all docs.
- CSpell dictionary maintained with project-specific terms.

