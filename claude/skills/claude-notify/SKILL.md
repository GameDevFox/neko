---
name: claude-notify
description: Send the user a Telegram notification from any local Claude Code session on this machine. Use this skill proactively whenever: the user says "notify me when done", "ping me", "let me know when finished", "send me a message", or any similar phrase; a long-running autonomous task completes; an all-nighter or extended session wraps up; or any situation where the user is likely away and would benefit from a heads-up that Claude has finished work. Don't wait to be asked twice — if the task is the kind that takes a while and the user might walk away, send a notification at the end.
---

# claude-notify — Telegram Notifications

Send the user a Telegram message directly from the terminal.

## Command

```bash
claude-notify "Your message here"
```

- Already on PATH (lives in `~/neko/bin/claude-notify`)
- Credentials are pre-configured on this machine — no setup needed
- Default message if no argument is given: `"Done"`

## When to use

- User asked to be notified when a task finishes
- End of a long autonomous session (all-nighter, extended build, etc.)
- Something important completed or failed and the user is likely not watching

## Examples

```bash
claude-notify "Done — all tests passing, PR is open"
claude-notify "Build failed on step 3, needs your attention"
claude-notify "Migration complete — 42 records updated"
```

Keep messages short and specific. Lead with the outcome, then a key detail if useful.

## Limitations

This script reads credentials from local files (`~/claude-telegram-bot-token`, `~/claude-telegram-chat-id`). It only works in local Claude Code sessions on this machine. Remote or scheduled agents cannot read those files — they must embed the token and chat ID directly in their prompt or environment.
