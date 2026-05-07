# TODO

- [x] Set up Telegram bot for Claude notifications — bot token at ~/claude-telegram-bot-token, chat ID at ~/claude-telegram-chat-id
- [x] Set up scheduled reminder for GitHub PAT expiry — routine trig_016sRX1riuSyJTEPH8KpWZG4 fires 2026-07-20, Telegram notification sent before token expires 2026-08-02
- [ ] Audit global web access permissions in ~/.claude/settings.json (WebSearch, WebFetch added 2026-05-04) — review monthly
- [ ] Find a secure method for storing and restoring machine-local credentials between new machine setups — migrate GitHub PAT (`~/claude-github-pat.txt`) and Telegram bot token/chat ID (`~/claude-telegram-bot-token`, `~/claude-telegram-chat-id`) from plaintext `~/` files to encrypted-at-rest storage (e.g. system keychain via secret-tool)
- [ ] Add branch protection to ark repo (master branch: prevent force pushes + deletions) — once commits are pushed
- [ ] Monthly GitHub audit — check every repo has branch protection on master (exceptions: openclaw and rustlings use main and have upstream branches, skip those) — last audited: 2026-05-04, next due: 2026-06-04
- [ ] Decide: make private repos public OR upgrade to GitHub Pro to enable branch protection on remaining 12 private repos (brigham-young-dating-sim, everempire, final-alchemy, kitsune, kitsune-rust, lessons, mastery, os-scripts, qarcade, referendum)
- [ ] Research and experiment with skipping the auto mode confirmation prompt — options: --dangerously-skip-permissions, --permission-mode bypassPermissions, or --permission-mode acceptEdits; find the safest approach that doesn't require manual pane interaction
- [ ] Set up home network to serve multiple apps (frontend + API) over HTTPS using owned domain names with signed certificates
