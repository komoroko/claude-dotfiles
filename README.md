# claude-dotfiles

［English | [日本語](README.ja.md)］

A dotfiles repository for sharing custom Claude Code scripts and settings across
multiple machines. The real files live here, and each machine links to them via
symlinks created by `install.sh`.

## Layout

```
claude-dotfiles/
├── bin/                     # Executables symlinked into ~/.local/bin (invoked via PATH)
│   ├── claude-notify        # Windows toast when a limit lifts (WSL only; auto-disabled elsewhere)
│   └── claude-resume        # Manual resume wrapper for after a limit lifts
├── claude/                  # Settings symlinked under ~/.claude
│   └── settings.json        # Claude Code settings (hooks are referenced via $HOME/.local/bin/)
├── install.sh               # Setup that creates the symlinks (idempotent)
├── .gitattributes           # Force LF endings (prevents CRLF creeping in from Windows)
└── .gitignore
```

## Setup

```bash
git clone <this repository's URL> ~/claude-dotfiles
cd ~/claude-dotfiles
./install.sh
```

`install.sh` moves any existing real file aside to `*.bak.<timestamp>` before
replacing it with a symlink. It is safe to run repeatedly.

## Dependencies

- `~/.local/bin` must be on your `PATH`
- `python3` (claude-notify / claude-resume)
- `claude-notify`'s toast notifications are WSL-only. On other systems
  `powershell.exe` is not found and it silently skips.

## Machine-specific / secret settings

This repository is public, so `claude/settings.json` must not hold anything you don't want to
publish (API keys, repository names, machine-specific paths, `autoMode` rules, etc.).
Claude Code does not read a user-level `~/.claude/settings.local.json`. Put such keys in a
drop-in file under `/etc/claude-code/managed-settings.d/` instead (for example
`sudo install -D -m 644 private.json /etc/claude-code/managed-settings.d/private.json`).
Claude Code merges it with this file at startup, and its keys take precedence over this file.
Settings for one project go in that project's `.claude/settings.local.json`.

## Design notes

- **Hook paths are `$HOME/.local/bin/<name>`.** In some environments the child
  processes spawned for hooks and the status line do not inherit `~/.local/bin`
  on their PATH, so a bare command name cannot be resolved. Relying on `$HOME`
  expansion still keeps things portable across differing usernames.
- **Line endings are pinned to LF** (`.gitattributes`). When the working tree
  lives on a Windows drive such as `/mnt/d`, an editor introducing CRLF turns
  the shebang into `python3\r` and the hook fails silently.
- **Executables have no file extension.** They follow the Unix convention of
  being shebang'd executables invoked by name from PATH.
- **Auto-resume is delegated to Claude Code's built-in behavior.** The former
  `claude-limit-hook` has been removed; this repo now only carries the
  lift notification (`claude-notify`) and a manual resume wrapper
  (`claude-resume`).
- **The status line is [ccstatusline](https://github.com/sirmalloc/ccstatusline).**
  The home-grown `claude-statusline` has served its purpose and was deleted.
- **Temporary files are isolated and auto-pruned.** The launchers/outputs
  generated on each rate_limit event are collected under
  `~/.claude/limit-resume/` and `~/.claude/limit-notify/` so they don't clutter
  `~/.claude` itself. On startup each script auto-deletes `.sh`/`.out` files
  older than `ARTIFACT_TTL_DAYS` (default 7 days); logs are exempt.
- **Default permission mode is `auto`** (`permissions.defaultMode`). This newer
  mode has an AI classifier judge the safety of each tool call and
  auto-approve accordingly; it falls back to normal mode on unsupported
  environments (model/plan) instead of failing closed.

## License

[MIT](LICENSE)
