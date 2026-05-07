# Claude Max: Scheduled / Remote Agent Cost & Usage Report

**Research date:** 2026-05-04

---

### 1. Are Routines Included in Claude Max, or Billed Separately?

**Routines are included in your Max subscription, but they consume from your shared usage pool — not a separate bucket.**

Claude Code **Routines** (launched April 14, 2026 in research preview) are the official Anthropic mechanism for scheduled/cloud-hosted agents:

- Available on Pro, Max, Team, and Enterprise plans.
- Routine runs **draw down the same subscription usage pool** that interactive Claude and Claude Code sessions use. No separate line item appears on your bill.
- When you exceed your plan's included usage, further runs become **"extra usage"** billed at standard API token rates (opt-in; you can disable it to prevent surprises).
- Routines are **not** the same as Claude Managed Agents, which is a fully API-billed product with no subscription inclusion.

**Critical gotcha:** If Claude Code is authenticated via an `ANTHROPIC_API_KEY` environment variable instead of your subscription credentials, all usage — including routine runs — is billed to your API account at pay-as-you-go rates. This has caused surprise bills of $1,800+ in two days for Max subscribers.

---

### 2. How Is Usage Measured?

Two billing components for Routines:

| Component | Unit | Rate |
|---|---|---|
| Token consumption | Per million tokens (input / output / cache) | Standard API model rates |
| Runtime | Per session-hour (active execution only) | $0.08/session-hour |

Runtime accrues only while the session is actively executing — idle/wait time does not count. A 45-second run costs ~$0.001 in runtime. A 15-minute run costs ~$0.02.

Within subscription limits, these costs are absorbed into the flat monthly fee. Extra usage beyond subscription limits is billed at the token rates below.

---

### 3. Practical Cost at Different Scales

**Assumptions for a lightweight Telegram reminder agent:**
- Model: Haiku 4.5 ($1.00/M input, $5.00/M output) — ideal for lightweight, fast tasks
- Tokens per run: ~1,000 total (500–1,000 input, 100–300 output)
- Runtime per run: ~15–30 seconds

| Scale | Monthly Runs | Tokens | Token Cost (API rate) | Runtime Cost | Total at API Rates | Within Max? |
|---|---|---|---|---|---|---|
| 1/day | 30 | ~30K | ~$0.03 | ~$0.01 | **~$0.04/mo** | Yes — negligible |
| 100/month | 100 | ~100K | ~$0.10 | ~$0.03 | **~$0.13/mo** | Yes — very negligible |
| 100/day | 3,000 | ~3M | ~$3.00 | ~$1.00 | **~$4.00/mo** | Exceeds daily run cap (see below) |

---

### 4. Rate Limits and Quotas

**Routines daily run cap (research preview, as of April 2026):**

| Plan | Daily Routine Runs |
|---|---|
| Pro ($20/mo) | 5/day |
| Max 5x ($100/mo) | 15/day |
| Max 20x ($200/mo) | 15/day |
| Team / Enterprise | 25/day |

- Runs over the cap are rejected unless extra usage is enabled (then billed at API rates).
- The usage pool is **shared** across claude.ai web, Claude Code CLI, Claude Desktop, and Routines. Heavy interactive use reduces the budget available for routines.
- Subscription usage also has a 5-hour rolling window and a 7-day weekly ceiling (the 5x/20x multipliers refer to these).

**Managed Agents API rate limits (for the API-direct path):**

| Limit | Value |
|---|---|
| Create endpoints | 60 req/min (org-level) |
| Read/status endpoints | 600 req/min (org-level) |
| Daily spend ceiling | $2,000/day per account |

---

### 5. Routines vs. Managed Agents

| | Claude Code Routines | Claude Managed Agents |
|---|---|---|
| Launch | April 14, 2026 (research preview) | April 8, 2026 (public beta) |
| Billing | Draws from Max subscription + $0.08/hr for overages | Always API-billed: tokens + $0.08/session-hour |
| Included in Max? | Yes (within 15/day cap) | No — pure pay-as-you-go |
| Daily run limit | 15/day (Max) | None (API rate limits only) |
| Best for | Scheduled tasks you describe in a Claude Code session | Long-running stateful agents with custom MCP servers |
| Session model | Fresh session per run, terminates on completion | Persistent sessions with file system and conversation history |

**For a simple Telegram reminder: Routines is the right choice.** It runs within your Max subscription, the absolute cost is negligible, and there's no API key complexity.

---

### 6. Summary Table

| Scenario | Feasibility on Max | Effective Cost | Key Limit |
|---|---|---|---|
| 1 reminder/day | Fully included | ~$0 above subscription | Uses 1 of 15 daily slots |
| 100 reminders/month (~3.3/day) | Fully included | ~$0 above subscription | Uses ~3 of 15 daily slots |
| 100 reminders/day | Exceeds Routines cap | ~$4/mo at API rates | 15/day cap; use API directly |

**Bottom line:**
- At 1/day or 100/month: well within Max, zero marginal cost.
- At 100/day: the **daily run cap** (not money) is the blocker. The API cost is trivially cheap (~$4/month), so at that scale call the Claude API (or Managed Agents API) directly from an external scheduler.
- Always verify authentication path (subscription vs. API key) to avoid surprise billing.

---

### Sources
- [Claude Managed Agents overview — API Docs](https://platform.claude.com/docs/en/managed-agents/overview)
- [Introducing routines in Claude Code — Anthropic Blog](https://claude.com/blog/introducing-routines-in-claude-code)
- [Claude Code routines — The Register](https://www.theregister.com/2026/04/14/claude_code_routines/)
- [Claude Managed Agents Pricing — WaveSpeedAI](https://wavespeed.ai/blog/posts/claude-managed-agents-pricing-2026/)
- [Claude Code Pricing 2026 — Finout](https://www.finout.io/blog/claude-code-pricing-2026)
- [Manage extra usage — Claude Help Center](https://support.claude.com/en/articles/12429409-manage-extra-usage-for-paid-claude-plans)
- [Rate limits — Claude API Docs](https://platform.claude.com/docs/en/api/rate-limits)
- [Plans & Pricing — Claude](https://claude.com/pricing)
