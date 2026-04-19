# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Personal zsh environment bootstrap: a `.zshrc` (oh-my-zsh, `agnoster` theme, aliases for modern CLI replacements) paired with `setup.sh` (installs the packages those aliases rely on). These two files are tightly coupled — editing one usually means editing the other.

## Commands

- Install/refresh the environment: `./setup.sh` — detects `apt`/`dnf`/`pacman`/`brew` and installs `PACKAGES`, copies this repo's `.zshrc` to `~/.zshrc` (timestamped backup if the existing file is a real file, not a symlink), then downloads JetBrainsMono Nerd Font to `~/.local/share/fonts/NerdFonts` (skipped if that dir exists).
- The `.zshrc` here is the source of truth; `setup.sh` overwrites `~/.zshrc` on every run, so make edits here and re-run the script rather than editing `~/.zshrc` directly.

## Adding a new CLI tool

The header comment in `setup.sh` defines the contract — all three steps must be done together or the banner/alias state drifts:

1. Add the package name to `PACKAGES` in `setup.sh`, OR to `OPTIONAL_PACKAGES` if it isn't in every supported distro/release (e.g. `fastfetch` is absent from Ubuntu 24.04 LTS). Optional packages are installed best-effort and never abort the script. For tools that aren't packaged at all, use a separate install block like `install_nerd_font`.
2. Add a row to the `cat <<'EOF' ... EOF` banner near the top of `.zshrc` so it shows up in the startup tool list.
3. Add any aliases in `.zshrc` with inline `#` comments describing them. If the tool may be absent (i.e. it's in `OPTIONAL_PACKAGES`), guard usage with `command -v <tool> >/dev/null` — see the `fastfetch`/`neofetch` startup block at the top of `.zshrc`.

## Notes on conventions already in the file

- `bat` is aliased conditionally: Debian/Ubuntu ship it as `batcat`, so there's a `command -v batcat` guard before aliasing `bat=batcat`. Preserve that pattern for any tool with a known distro rename.
- `cat` and `less` are globally overridden to `bat` variants. Anything that expects raw `cat` output from an interactive shell will be affected — use `command cat` to bypass.
- `nvm` and `bun` both mutate `PATH`; `pnpm` guards against double-prepending with a `case` check. Follow the guarded pattern when adding anything else that extends `PATH`.
