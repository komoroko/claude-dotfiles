# claude-dotfiles

［[English](README.md) | 日本語］

Claude Code の自作スクリプトと設定を複数マシンで共通利用するための dotfiles リポジトリ。
実体はこのリポジトリに置き、各マシンからは `install.sh` が symlink を張る。

## 構成

```
claude-dotfiles/
├── bin/                     # ~/.local/bin へ symlink される実行スクリプト（PATH 経由で起動）
│   ├── claude-notify        # limit 解除時に Windows トースト通知（WSL 用、非WSLでは自動無効）
│   └── claude-resume        # limit 解除後の手動再開ラッパー
├── claude/                  # ~/.claude 配下へ symlink される設定
│   └── settings.json        # Claude Code 設定（hook は $HOME/.local/bin/ 経由で参照）
├── install.sh               # symlink を張るセットアップ（冪等）
├── .gitattributes           # 改行は必ず LF（Windows 側編集での CRLF 混入防止）
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
- `python3`（claude-notify / claude-resume）
- `claude-notify` のトースト通知は WSL 環境専用。他 OS では `powershell.exe` が見つからず静かにスキップされる。

## マシン固有・秘密の設定

共有したくない設定（API キー、マシン固有のパス等）は
`~/.claude/settings.local.json` に置く。これは symlink 対象外かつ gitignore 済み。

## 設計メモ

- **hook のパスは `$HOME/.local/bin/<name>`**。hook や statusLine の子プロセスには
  `~/.local/bin` が PATH に入らない環境があるため、コマンド名だけでは解決できない。
  `$HOME` 展開に頼ることでユーザー名が異なるマシンでもそのまま動く。
- **改行は LF 固定**（`.gitattributes`）。作業ツリーが `/mnt/d` 等 Windows 側にある場合、
  エディタが CRLF を混入させるとシェバンが `python3\r` になり hook が無言で失敗する。
- **実行スクリプトに拡張子は付けない**。shebang 付きの実行ファイルとして PATH から名前で呼ぶ Unix 慣習に従う。
- **自動再開は Claude Code 標準機能に一本化**。以前あった `claude-limit-hook` は削除し、
  リポジトリ側は解除通知（`claude-notify`）と手動再開ラッパー（`claude-resume`）のみを持つ。
- **ステータスラインは [ccstatusline](https://github.com/sirmalloc/ccstatusline) を利用**。
  自前の `claude-statusline` は役目を終えたため削除した。
- **一時ファイルは隔離＋自動削除**。rate_limit 発火ごとに生成されるランチャー/出力は
  `~/.claude/limit-resume/`・`~/.claude/limit-notify/` 配下にまとめ、`~/.claude` 直下を汚さない。
  各スクリプト起動時に `ARTIFACT_TTL_DAYS`（既定7日）より古い `.sh`/`.out` を自動削除する（ログは対象外）。
- **デフォルトの権限モードは `auto`**（`permissions.defaultMode`）。AI 分類器がツール呼び出しの安全性を判定して自動承認する新モードで、非対応環境（モデル/プラン等）では通常モードへ自動フォールバックするため事故りにくい。

## ライセンス

[MIT](LICENSE)
