# claude-dotfiles

［English | [日本語](README.ja.md)］

A dotfiles repository for sharing custom Claude Code scripts and settings across
multiple machines. The real files live here, and each machine links to them via
symlinks created by `install.sh`.

## Layout

```
claude-dotfiles/
├── bin/                     # Executables symlinked into ~/.local/bin (invoked via PATH)
│   ├── claude-limit-hook    # Dispatcher for the StopFailure(rate_limit) hook
│   ├── claude-notify        # Windows toast when a limit lifts (WSL only; auto-disabled elsewhere)
│   ├── claude-resume        # Auto-resume after a limit lifts
│   └── claude-statusline    # Status line renderer
├── claude/                  # Settings symlinked under ~/.claude
│   └── settings.json        # Claude Code settings (hook / statusLine reference commands by name on PATH)
├── install.sh               # Setup that creates the symlinks (idempotent)
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
- `python3` (claude-limit-hook / claude-notify / claude-resume)
- `jq`, `bc` (claude-statusline)
- `claude-notify`'s toast notifications are WSL-only. On other systems
  `powershell.exe` is not found and it silently skips.

## Machine-specific / secret settings

Put anything you don't want to share (API keys, machine-specific paths, etc.) in
`~/.claude/settings.local.json`. It is not symlinked and is gitignored.

## Design notes

- **Hook paths are command names only** (`claude-limit-hook`, etc.). Avoiding
  absolute paths lets them work unchanged on machines with different usernames
  and home directories (assuming `~/.local/bin` is on PATH).
- **Executables have no file extension.** They follow the Unix convention of
  being shebang'd executables invoked by name from PATH.
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
