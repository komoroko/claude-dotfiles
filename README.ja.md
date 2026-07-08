# claude-dotfiles

［[English](README.md) | 日本語］

Claude Code の自作スクリプトと設定を複数マシンで共通利用するための dotfiles リポジトリ。
実体はこのリポジトリに置き、各マシンからは `install.sh` が symlink を張る。

## 構成

```
claude-dotfiles/
├── bin/                     # ~/.local/bin へ symlink される実行スクリプト（PATH 経由で起動）
│   ├── claude-limit-hook    # StopFailure(rate_limit) hook のディスパッチャ
│   ├── claude-notify        # limit 解除時に Windows トースト通知（WSL 用、非WSLでは自動無効）
│   ├── claude-resume        # limit 解除後の自動再開
│   └── claude-statusline    # ステータスライン表示スクリプト
├── claude/                  # ~/.claude 配下へ symlink される設定
│   └── settings.json        # Claude Code 設定（hook / statusLine は PATH 上のコマンド名で参照）
├── install.sh               # symlink を張るセットアップ（冪等）
└── .gitignore
```

## セットアップ

```bash
git clone <このリポジトリの URL> ~/claude-dotfiles
cd ~/claude-dotfiles
./install.sh
```

`install.sh` は既存の実ファイルを `*.bak.<timestamp>` へ退避してから symlink に置き換える。
再実行しても安全。

## 依存

- `~/.local/bin` が `PATH` に含まれていること
- `python3`（claude-limit-hook / claude-notify / claude-resume）
- `jq`, `bc`（claude-statusline）
- `claude-notify` のトースト通知は WSL 環境専用。他 OS では `powershell.exe` が見つからず静かにスキップされる。

## マシン固有・秘密の設定

共有したくない設定（API キー、マシン固有のパス等）は
`~/.claude/settings.local.json` に置く。これは symlink 対象外かつ gitignore 済み。

## 設計メモ

- **hook のパスはコマンド名のみ**（`claude-limit-hook` 等）。絶対パスを書かないことで、
  ユーザー名・ホームディレクトリが異なるマシンでもそのまま動く（`~/.local/bin` が PATH 前提）。
- **実行スクリプトに拡張子は付けない**。shebang 付きの実行ファイルとして PATH から名前で呼ぶ Unix 慣習に従う。
- **一時ファイルは隔離＋自動削除**。rate_limit 発火ごとに生成されるランチャー/出力は
  `~/.claude/limit-resume/`・`~/.claude/limit-notify/` 配下にまとめ、`~/.claude` 直下を汚さない。
  各スクリプト起動時に `ARTIFACT_TTL_DAYS`（既定7日）より古い `.sh`/`.out` を自動削除する（ログは対象外）。

## ライセンス

[MIT](LICENSE)
