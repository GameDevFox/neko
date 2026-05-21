# neko

Personal dotfiles and utility scripts repository for Edward Nicholes Jr. (GameDevFox). Cloned to `~/neko` on every new Linux setup — the source of truth for shell config, window manager setup, editor preferences, and system utilities.

## Purpose

Bootstrap a new Linux system and keep config consistent across machines. After cloning, run `bin/link-neko` to symlink everything from `config/` into `$HOME/`, then the shell picks up `bin/` automatically via PATH.

## Directory Layout

```
bin/       Utility scripts — added to PATH via .zshrc/.profile
config/    Dotfiles — mirrors $HOME structure, symlinked by link-neko
              Symlinks in config/ are mirrored as symlinks at destination (not traversed)
claude/    Claude Code config: skills/ directory (linked via config/.claude/skills)
shell/     Shell config sourced by .zshrc: commonrc, alias, functions
os/        OS-specific install scripts and package lists
  arch/    Primary: install, setup, grub-setup scripts + package lists
  debian/  Package lists
  gentoo/  World file and setup notes
  osx/     macOS extras
  windows/ Windows setup
common/    Dev config templates (eslint, VS Code)
desktop/   Wallpaper assets
misc/      VS Code snippets, reference docs (e.g. claude-agent-cost-report.md)
TODO.md    Canonical to-do list (open + completed items)
```

## Bootstrap Flow

1. Fresh Arch install: run `os/arch/install` from live ISO
2. Chroot and run `os/arch/setup` (timezone, locale, create user `fox`, sudoers)
3. After first boot as `fox`: clone repo to `~/neko`, run `bin/link-neko`
4. Shell sources `.zshrc` → loads all config, adds `~/neko/bin` to PATH

## Installation: link-neko

`bin/link-neko` walks `config/` and creates symlinks at the corresponding path in `$HOME/`. It skips anything already linked. It does **not** overwrite existing files — run manually if replacing a non-symlink file.

Files in `config/` map directly: `config/.zshrc` → `~/.zshrc`, `config/.config/i3/config` → `~/.config/i3/config`, etc.

Symlinks found in `config/` are replicated as symlinks at the `$HOME` destination, pointing to the same resolved target (not traversed file-by-file).

**Editing dotfiles:** Always edit the `config/` source, not the `$HOME` symlink. The Edit tool refuses to write through symlinks, so editing `~/.zshrc` or `~/.claude/CLAUDE.md` directly will fail — use the `config/` path instead (e.g. `config/.zshrc`, `config/.claude/CLAUDE.md`).

## Shell Config

- **`.zshrc`** — Zsh options, history (1M entries), prompt, global aliases, key widgets
- **`shell/commonrc`** — Shared between shells: PATH additions, env vars, sources alias + functions
- **`shell/alias`** — All aliases including extensive git shortcuts (`g`, `ga`, `gb`, `gco`, `gd`, `gp`, etc.)
- **`shell/functions`** — Shell functions: `md`, `bookmark`, `gurl`, `gclone`, `gnl`, docker helpers

Key env vars set by shell config:
- `NEKO=$HOME/neko`
- `EDITOR=vim`
- `PAGER=less` with `LESS='-SRX'`

Local overrides live in `~/.neko/` (not tracked): `.zshrc`, `.gitconfig`, `bookmarks`, `vimrc`.

## Bin Scripts

45+ scripts. Key categories:

**Git:** `git-current-branch`, `git-last-branch`, `git-outdated`, `git-usage`, `git-pull-all`, `git-as-gamedevfox`, `git-as-prince86eknj`

**Projects:** `projects-list`, `projects-outdated`, `projects-fetch`, `project-open` (rofi-based VS Code opener)

**Display:** `screen-layout-set` (named xrandr presets), `install-wallpaper`, `monitor-ls`, `monitor-sleep-enable/disable`

**System/Security:** `lock-screen`, `key-install` (KeePassXC SSH key extraction), `monero-update` (encrypted volume + daemon), `block-device-list`

**Utilities:** `cols`, `lines`, `filter-comments`, `open-term`, `fork`, `service` (restart-on-crash)

When adding a new script: put it in `bin/`, make it executable (`chmod +x`), use a `#!/bin/bash` or `#!/usr/bin/env <lang>` shebang. No install step needed — `bin/` is already on PATH.

**Passthrough convention:** Scripts that wrap or route to another command must pass `"$@"` through — never re-parse or re-declare args. The destination owns its own argument handling.

## Config Files

**i3** (`config/.config/i3/config`): Super as mod key, 20px inner gaps, 3-monitor workspace layout (DP-1 left, HDMI-2 center, DP-2 right), Rofi launcher, lock screen via `bin/lock-screen`.

**i3status** (`config/.config/i3status/config`): The public config is `config.public` (tracked). `config.private` is gitignored — for machine-specific overrides. The symlinked `config` file should point to or include the appropriate variant.

**Vim** (`.vimrc`): Syntax highlighting, smart indent, custom whitespace commands. Sources `~/neko/local/vimrc` for local overrides.

**Tmux** (`.tmux.conf`): 256-color, 99K history, arrow-key pane navigation.

**Git** (`.gitconfig`): `useConfigOnly = true`, default branch `master`, push default `current`, fetch prune enabled. Per-directory overrides via `.neko/.gitconfig`.

## OS Package Lists

Arch packages are split into `os/arch/packages` (base list) and `os/arch/packages.d/` (modular categories: audio, aur, bluetooth, desktop, display-manager, japanese, media, tablet, wifi, etc.).

When adding a new package dependency: add it to the appropriate file in `packages.d/` or to `packages` if it's universal.

## Git Remotes

- `origin` → GitHub (GameDevFox)
- `gitlab` → GitLab (GameDevFox)

Push to both when making changes that should persist across systems. Pull with `neko-pull` alias (defined in shell/alias).

## What NOT to Track

- `~/.neko/` — machine-local overrides (bookmarks, local zshrc, local gitconfig)
- Private/sensitive files (SSH private keys, credentials)
- `config/.config/i3status/config.private` — machine-specific status bar config
- Generated or cached files

## Machine-Local Credentials

Key machine-specific files in `~/.neko/` that must be recreated on each new machine:
- `.gitconfig` — git email + GitHub credential helper
- `git-credential-github` — script that reads `~/claude-github-pat.txt` and outputs GitHub credentials

GitHub credentials:
- PAT stored at `~/claude-github-pat.txt` (permissions: 600)
- Credential helper at `~/.neko/git-credential-github` (executable)
- Only applies to `https://github.com` URLs via `[credential "https://github.com"]` in `~/.neko/.gitconfig`

Telegram bot credentials for Claude notifications:
- Bot token: `~/claude-telegram-bot-token` (permissions: 600)
- Chat ID: `~/claude-telegram-chat-id` (permissions: 600)

To send a Telegram notification from a local session:
```bash
curl -s -X POST "https://api.telegram.org/bot$(cat ~/claude-telegram-bot-token)/sendMessage" \
  -d "chat_id=$(cat ~/claude-telegram-chat-id)&text=YOUR+MESSAGE"
```

Note: remote/scheduled agents cannot read local files — embed the token and chat ID directly in the routine prompt if needed.

## GitHub Token

A fine-grained PAT for Claude's GitHub access was created on 2026-05-04. It **expires 2026-08-02** (Sunday). Renew it before that date at GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens.

A scheduled routine (`trig_016sRX1riuSyJTEPH8KpWZG4`) is already set up to send a Telegram reminder on 2026-07-20 (2 weeks before expiry).

Remind the user to renew this token if the current date is within 2 weeks of 2026-08-02.

## Project Sessions

Projects live under `~/projects/`. Each project can have a named tmux Claude CLI session.

### Listing Sessions

When the user says **"list"** or **"list sessions"**, run:

```bash
tmux list-sessions 2>/dev/null
```

Display the results as a numbered list, e.g.:

```
1. kitsune (running, 5 minutes)
2. everempire-api (running, 23 minutes)
3. workout-waifu (running, 1 hour)
```

Remember the number-to-session mapping for the rest of the conversation. After displaying the list, wait for the user to reference a number.

### Interacting with a Session by Number

When the user references a session by number, ask what they'd like to do with it. Options:

- **Status** — show current pane output: `tmux capture-pane -t <name> -p -S -50`
- **Kill** — `tmux kill-session -t <name>`
- **Restart** — kill then start a new session (see Starting a Session below)
- **Kill and restart** — same as restart

If the user says a session is **stuck**, follow this recovery escalation — stop as soon as one step works:

**Step 1 — Interrupt and continue (try first):**
```bash
tmux send-keys -t <name> C-c
```
Wait 2–3 seconds, check if the session is responsive, then send the resume message (see below).

**Step 2 — Graceful exit and resume (if Step 1 didn't fix it):**
Send Ctrl+C twice to exit Claude Code, which emits the session UUID on exit:
```bash
tmux send-keys -t <name> C-c && sleep 1 && tmux send-keys -t <name> C-c
```
Wait for the session to close, then find the UUID. From a real terminal (e.g. a tmux window), `claude --resume` (no args) opens an interactive TUI picker listing all sessions across all projects, each showing a summary of the last message, relative timestamp, branch, and conversation size. Navigate with arrow keys, search by typing, Space to preview, Ctrl+R to rename, Ctrl+A to show all projects, Ctrl+B to filter to current branch.

**Note:** `claude --resume` without a UUID does NOT work from the agent's Bash tool — Claude Code runs in `--print` mode internally, which requires a UUID. From the agent side, find the UUID by listing session files directly:
```bash
ls -lt ~/.claude/projects/<project-dir-slug>/ | head -3
```
Restart with `--resume <uuid>`:
```bash
tmux new-session -d -s <name> -n <name> -c ~/projects/<name> 'claude --remote-control --resume <uuid>'
```
Then send the resume message (see below).

**Step 3 — Hard restart (last resort):**
Kill and restart from scratch (original behavior — loses conversation history).

### Resume Message

After Steps 1 or 2, send this message to the session prompt:

> The previous session got stuck (likely on a long-running command). This session has been resumed — you have full context of what was done. Please pick up where you left off. If a command was interrupted mid-run, re-run it. Do not start over or re-explain what was already completed.

### Starting a Session

Use `launch-claude-session` (or `neko claude`) to start a session. It always includes `--remote-control`, names the session after the project, and names the first window `claude`. `neko` runs from `~/neko`; all other names run from `~/projects/<name>`.

```bash
# Default: neko session
neko claude

# Any project under ~/projects/
neko claude <name>

# With a permission mode (all extra args pass through to launch-claude-session)
neko claude <name> --permission-mode acceptEdits
neko claude <name> --permission-mode auto
```

To start manually (e.g. with `--resume`), always include `--remote-control` and name the first window `claude`:

```bash
tmux has-session -t <name> 2>/dev/null  # check first
tmux new-session -d -s <name> -n claude -c ~/projects/<name> 'claude --remote-control'
tmux new-session -d -s <name> -n claude -c ~/projects/<name> 'claude --remote-control --resume <uuid>'
```

To browse and pick a session interactively, run `claude --resume` (no UUID) from a real terminal (e.g. a tmux window) — it opens a TUI picker listing all resumable sessions with summaries, timestamps, and sizes. This does not work from the agent's Bash tool (requires `--print` mode, which needs a UUID).

## Cloning Projects

The user's GitHub account is **GameDevFox** (`github.com/GameDevFox`). SSH is not configured on this machine — use HTTPS (the credential helper handles auth automatically):

```bash
git clone https://github.com/GameDevFox/<repo>.git ~/projects/<repo>
```

For repos owned by others or on other hosts, ask for the full URL if not provided, then clone:

```bash
git clone <url> ~/projects/<name>
```

After cloning, ask if they want to start a Claude session for it. If the directory already exists, warn the user before proceeding.

## Branch Management

When the user asks about branches for a project, operate from its directory (`~/projects/<name>`).

- **List branches** (local + remote): `git branch -a`
- **Current branch**: `git branch --show-current`
- **Switch branch**: `git checkout <branch>` (or `git switch <branch>`)
- **Create and switch**: `git checkout -b <branch>`
- **Delete local branch**: `git branch -d <branch>` (use `-D` only if user confirms force-delete)
- **Delete remote branch**: confirm with user before running `git push <remote> --delete <branch>`

Always show the current branch when giving branch status.

## Remote Sync

When the user wants to sync or check remotes for a project:

- **List remotes**: `git remote -v`
- **Fetch all remotes**: `git fetch --all --prune`
- **Show ahead/behind status**: `git status -sb` or `git branch -vv`
- **Pull current branch**: `git pull`
- **Pull with rebase**: `git pull --rebase`
- **Push current branch**: confirm with user before pushing; use `git push -u origin <branch>` for new branches

For **force push**, always ask for explicit confirmation and warn about overwriting remote history. Never force-push to `main` or `master` without a strong explicit reason from the user.

To check all projects for unpushed changes at once:

```bash
for d in ~/projects/*/; do
  [ -d "$d/.git" ] && echo "=== $d ===" && git -C "$d" status -sb 2>/dev/null
done
```

## To-Do List

Whenever the user asks to add something to a to-do list, add it to `~/neko/TODO.md` in addition to using the TaskCreate tool. Use standard markdown checkbox format: `- [ ] item`.

