# TODO

- [ ] Audit global web access permissions in ~/.claude/settings.json (WebSearch, WebFetch added 2026-05-04) — review monthly
- [ ] Find a secure method for storing and restoring machine-local credentials between new machine setups — migrate GitHub PAT (`~/claude-github-pat.txt`) and Telegram bot token/chat ID (`~/claude-telegram-bot-token`, `~/claude-telegram-chat-id`) from plaintext `~/` files to encrypted-at-rest storage (e.g. system keychain via secret-tool)
- [ ] Add branch protection to ark repo (master branch: prevent force pushes + deletions) — once commits are pushed
- [ ] Monthly GitHub audit — check every repo has branch protection on master (exceptions: openclaw and rustlings use main and have upstream branches, skip those) — last audited: 2026-05-04, next due: 2026-06-04
- [ ] Decide: make private repos public OR upgrade to GitHub Pro to enable branch protection on remaining 12 private repos (brigham-young-dating-sim, everempire, final-alchemy, kitsune, kitsune-rust, lessons, mastery, os-scripts, qarcade, referendum)
- [ ] Research and experiment with skipping the auto mode confirmation prompt — options: --dangerously-skip-permissions, --permission-mode bypassPermissions, or --permission-mode acceptEdits; find the safest approach that doesn't require manual pane interaction
- [ ] Set up home network to serve multiple apps (frontend + API) over HTTPS using owned domain names with signed certificates
- [ ] Koneko: token auth on the listener (currently open on the overlay + local wifi)
- [ ] Koneko: switch service type dataSync → specialUse when phone hits Android 15 (boot-start restriction)
- [ ] Koneko: create GitHub repo and push initial commit
- [ ] Koneko v2: control panel — tmux session list across machines (spec interviewed + recorded: `~/projects/koneko/docs/control-panel.md`); later: pane peek, quick actions on notifications (approve/respond/restart), home system stats (machine health, services, NetBird peers)
- [ ] Set up a file-drop for ad-hoc transfers (e.g. APK builds to the phone) — S3/R2 bucket, or self-host on the existing VPS (vpn.gamedevfox.org) since it's already public; relates to the HTTPS-serving item above. Beats serving from the laptop through the NetBird relay (slow when phone is on cellular)
- [ ] Sync Claude Code hooks across machines via neko — `~/.claude/settings.json` is machine-local; consider tracking it in `config/.claude/` (link-neko symlink) with machine-specific values (model, theme) split out, or a `claude-hooks-install` script that merges the hooks block into the local settings.json
- [ ] Re-run gemma-4-12b HumanEval truncated tasks and merge — its 62.2% (2026-07-22) is a FLOOR, not a real score: ~41% of responses hit the 2048-token limit and scored as false negatives. Fix: `cd ~/lab/benchmarks && python3 retry_truncated.py gemma-4-12b --from-log '2026-07-22 06:52' --max-tokens 8192` (needs LM Studio running with gemma-4-12b loaded; re-runs only truncated tasks and overlays them on the passes, which are already valid)
- [ ] Backport resumability to humaneval.py (per-task checkpoint + skip-completed on relaunch) — same principle now in the roleplay harness; would've saved the Gemma re-runs
- [ ] Migrate desktop from ding-server (:1234) → neko-server (:6356): set `NEKO_DING_SOUND` to the desktop's ding audio file, run neko-server on 6356, retire old ding-server
- [ ] Persistent neko-server launch on each machine (systemd user unit or `bin/service`) — the `node --watch` tmux window is dev-only, won't survive reboot
- [ ] neko-server services layer (deferred): `/services` list + start/stop delegating to `gpu-service` (add `--json`); later a `/fleet` endpoint aggregating peer machines (peer list in `~/.neko/`)
