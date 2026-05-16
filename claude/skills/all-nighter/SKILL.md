---
name: all-nighter
description: Run an autonomous coding session while the user is away or otherwise unavailable for an extended stretch — overnight sleep, a workday, a weekend trip, etc. Invoked explicitly via /all-nighter. Walks through a short interactive kickoff (project scan, pending-WIP handling, goal/budget/boundary/duration interview, plan confirmation, safety-net scheduling), then runs autonomously with atomic commits, a structured session log, and a handoff summary. Scope and aggressiveness scale with the away duration. Do not trigger implicitly; only use when the user has clearly opted in.
---

# /all-nighter — Autonomous Away-Session Work

You are about to drive an autonomous work session while the user is away — sleeping, in meetings, traveling, or otherwise unable to respond for an extended period. The user has explicitly chosen this, and authorizes the rules below.

The away window can range from a couple of hours (lunch + an afternoon of meetings) to a few days (weekend trip, vacation). The plan and aggressiveness scale with the duration — see Phase 1.4.

The skill has two phases:

1. **Kickoff** — interactive, the user is present. You complete this *before* they leave.
2. **Autonomous run** — the user is gone and cannot respond. You work alone until you've genuinely exhausted productive avenues or the availability window closes, then write a handoff summary.

A third phase, **Continuation**, fires when a safety-net wake-up runs. Some AI runtimes impose some kind of session-level limit — a time-based quota, a token budget, a context-window cap, or a combination — after which a single agent invocation can no longer continue productively. For any away window longer than that limit, the run is split across multiple agent invocations connected through scheduled wakes. Read the bottom of this doc when a wake fires.

---

## Hard rules — these apply through the entire run

- **Never invoke any tool that prompts the user during the autonomous phase.** This includes `AskUserQuestion`, `ExitPlanMode`, any skill that opens an interactive flow, and tools that emit blocking confirmations. The user is unreachable; a blocking call freezes the session and burns the away window. These are fine during the *kickoff* phase only.
- **Never push to remotes.** No `git push`, no `git push --force`, no `gh pr create`, no `gh issue create`, no anything with externally visible side effects. Commits stay local.
- **Never run destructive git on the user's existing work.** No `git reset --hard` past the start of this run, no `git checkout --` on uncommitted files outside the skill's own working set, no `git branch -D` of branches the skill did not create.
- **Never touch off-limits paths** declared during kickoff (always-out: `.env` and any path the user names).
- **Never invent budgets.** If the user did not set a budget cap at kickoff, do not spend on paid services. If you discover that a paid service is needed and no cap was set, stop and write a note to the session log instead.

---

## Phase 1: Kickoff (interactive)

Move through this in order. Keep the user's reading load low — they're about to step away and probably don't have a lot of time.

### 1.1 Project scan (silent)

Quickly look at the working directory. Note for yourself, do not narrate:

- Is this a git repo? `git rev-parse --show-toplevel` — if not, ask the user whether to `git init` before continuing or abort.
- What language/stack? Check for `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `Gemfile`, etc.
- Is there a test command? Read `package.json` scripts, `Makefile`, `pyproject.toml`, etc.
- Is there a typecheck command? `tsconfig.json`, `mypy.ini`, etc.
- Is there a `TODO.md`, `BACKLOG.md`, `ROADMAP.md`, or similar?
- Is there a `.env` file? Are there imports of paid SDKs (Anthropic, OpenAI, OpenRouter, etc.) suggesting API spend matters?
- What's the current branch? Is there a remote?
- Is the working tree dirty?

Use what you find to tailor the kickoff interview. Skip questions whose answer is obviously irrelevant (don't ask about API budget if there's no paid SDK in the project; don't ask about TODO source if there's no TODO file).

### 1.2 Pending-WIP handling (interactive)

If the working tree is clean, skip this section.

If it's dirty, ask the user — one focused question with up to three options:

- **Commit to current branch** — stage everything and commit as a single "pending changes at start of away session" commit. Most common choice.
- **Stash to a side branch** — create a new branch like `wip-pending-<YYYY-MM-DD-HHmm>`, commit the WIP there, return to the working branch with a clean tree, leave the side branch for the user to restore later.
- **I'll commit it myself, wait** — pause until the user signals they're ready.

After this step, **the working tree must be clean** before the autonomous phase begins. Verify with `git status --porcelain` — empty output, nothing else accepted.

### 1.3 Kickoff interview (interactive)

Ask in one batch via `AskUserQuestion`. Tailor based on the project scan — skip irrelevant ones.

**Always asked:**

- **Primary goal** — what's the headline task? Free text. This is the "Primary" layer.
- **Availability window** — when do they expect to be back / reading the summary? (e.g. "8am tomorrow", "in 6 hours", "Monday morning", "Sunday evening"). Drives the stopping criterion *and* scales plan aggressiveness (see 1.4).
- **Off-limits** — files, branches, systems the skill must not touch. Free text, can be "nothing."

**Conditionally asked:**

- **Budget cap** — only if paid SDKs are detected. Single dollar amount. The skill enforces soft-warn at 80%, hard-stop at 100%.
- **Side-project bar** — only if a backlog source (TODO.md etc.) was detected. Three options: *Strict* (only the headline), *Backlog-driven* (headline then drift through the backlog), *Full latitude* (headline, then backlog, then agent-invented experiments). Default to *Full latitude* — the away window is wasted if the user comes back to just the headline (unless they explicitly asked for strict scope).
- **Tool extensions** — anything project-specific the skill should be allowed to call autonomously beyond the baseline allowlist (e.g. "you may run `pnpm bench` during this run, it makes API calls").

### 1.4 Plan drafting (interactive)

Based on the interview answers and (if available) the backlog source, draft a phase list and present it for confirmation.

Structure the plan in three layers:

| Layer | Source | Purpose |
|---|---|---|
| **Primary** | The headline goal | The thing the user explicitly asked for |
| **Backlog** | The detected backlog (TODO.md etc.) | Items the agent picks based on project priority and apparent readiness |
| **Stretch** | Agent-invented | Experimental ideas grounded in documented project concerns |

**Scale plan ambition to the availability window.** Active working time is roughly the away window minus 1-2 hours (waking up, getting ready, reading the summary). Rough calibration:

| Away window | Plan scope |
|---|---|
| **~2-4 hours** (lunch + meetings) | Primary only. Be picky — don't start work you can't finish. Stretch off unless something tiny and obviously useful comes up. |
| **~5-12 hours** (overnight sleep) | Primary + Backlog drift. Some Stretch if Primary completes well ahead of window. |
| **~24-48 hours** (workday-plus, weekend) | Primary + meaningful Backlog burn-down + planned Stretch experimentation. Pace yourself; multiple wake-cycles will run. |
| **3+ days** (vacation) | Treat each ~24h block as its own arc with its own handoff section in the session log. Don't try to hold one giant plan — let each continuation refresh the plan based on what's done. |

For Primary, break into 3-6 phases. Each phase should be concretely completable in 15-60 minutes of active work. Don't pre-plan Backlog and Stretch in detail — those evolve during the run.

Present the plan and ask: *"Plan looks right, or want to redirect anything before I start?"* Confirm before proceeding.

### 1.5 Safety net scheduling

Schedule wake-ups across the availability window using whatever durable scheduling mechanism your runtime provides (e.g. a `schedule` skill that registers cron-style runs on infrastructure independent of the current session). **Do not rely on in-session timers or crons** — those die when the session ends, defeating the safety net.

**Cadence: shorter than your agent's session limit.** That limit might be expressed in hours of wall time, tokens consumed, context-window size, or message count — whichever wall your runtime hits first. The goal is that a fresh agent invocation always picks up well before the previous one would run out of room.

- **If you know your platform's session limit**, set the wake interval to ~75-80% of it (leaves headroom for the wrap-up commit before the wall hits).
- **If you don't**, a conservative default of ~4 hours works for most current AI runtimes. Tune up or down as you learn the actual limit.

Scaling cadence to the away window (let `L` = your wake interval):

- **Window ≤ L:** one wake at ~75% of the window. Mainly a safety net in case the original session crashes early.
- **Window 1-3× L:** recurring every `L`, last fire near the end of the window.
- **Window 1-3 days:** recurring every `L` throughout. Multi-invocation runs are normal here.
- **Window 3+ days:** recurring every `L`, *and* at least one wake per "day-arc" boundary so each ~24h block can produce its own handoff section.

The wake prompt should embed:

- Path to the session-log file you are about to create (so the resumed agent can read state)
- The skill name to reactivate (`/all-nighter` continuation mode)
- The kickoff answers (primary goal, budget remaining, off-limits, availability window)
- Instruction to first decide *continue or wrap*, not blindly resume
- Reminder that the resumed agent cannot ask the user any questions either

Always schedule. The cost of unused wakes is negligible compared to losing a session to an unrecoverable wall-hit.

### 1.6 Create the session log + final handoff

Write `ALL-NIGHTER-<YYYY-MM-DD>.md` at the git root with these sections, empty placeholders for everything except the kickoff record. For multi-day runs, the agent will append further day-arc sections during continuations.

```markdown
# All-Nighter Session — <YYYY-MM-DD>

## TL;DR

*(filled in at wrap)*

## Kickoff record

Primary goal: ...
Availability window: ...   (when the user expects to be back)
Budget cap: ...
Off-limits: ...
Side-project bar: ...
Plan confirmed at: ...

## Plan

| Phase | Layer | Status |
|---|---|---|
| ... | Primary | pending |

## Decisions log

*(unilateral calls + reasoning, appended as you make them)*

## Findings

*(bench results, surprising behavior, dead ends worth knowing about)*

## Cost ledger

| When | What | Service/model | Estimate |
|---|---|---|---|

Running total: $0.00

## For your review

*(populated at wrap — punch list of what the user should look at first)*

## Open questions

*(things parked for the user when they come back)*
```

Confirm everything is in order, wish them a good [night / day / trip] as appropriate, then switch to the autonomous phase.

---

## Phase 2: Autonomous run

The user is gone. Work the plan.

### Layer progression: Primary → Backlog → Stretch

Run Primary phases first, in order. Do not skip ahead. When the last Primary phase is genuinely complete (tests green, commits made, session-log updated), move to Backlog. When Backlog is exhausted (or there's no clear next pick the user would value), move to Stretch.

In Stretch, you may invent experiments grounded in the project's documented concerns. Examples of good Stretch work:

- Variance-seeking benches that try to break the Primary work
- Cleanup pulled from inline TODO/FIXME comments
- Documentation gaps that surface as you read code
- Refactors that the Primary phases revealed but weren't in scope
- Small infrastructure improvements (gitignore additions, lint rule tightening, test coverage gaps)

What makes a Stretch idea worth pursuing:

- *Specific* and *concretely completable in this session*
- *Likely the user would say "good, I'm glad you did that"* — not "why did you spend the away window on this?"
- *Reversible in one revert + a few line removals* (see the deletability constraint below)

### Design constraint: deletability over togglability

Every change should be easy for the user to remove if they don't like it. The mental model is **"delete a few files and remove a few references"**, not "find the right feature flag."

Rules in practice:

- **Prefer new files to modifying existing ones**, but feel free to modify existing files when the modification *improves modularity, tests, or decoupling* — that's a win, not a risk.
- **Localize imports** — a new feature should be imported in as few places as possible. If five files end up importing your new module, ask whether the boundary is in the right place.
- **Commit messages name the delete path.** Example: *"To remove: delete `packages/X/feature-Y/`, remove the import in `Z.ts:42`."*
- **Feature flags are an escape hatch**, not the default. Use them only when runtime toggling is genuinely needed (e.g. the user wants to enable/disable on the fly without redeploying).
- **No surprise integrations.** If you wire a new feature into a core entry point, the commit message must call it out plainly.

### Commit cadence: atomic per logical unit

- One commit = one coherent change that can be reverted independently
- Commit after each logical step where tests pass
- Phase boundaries always get their own commit
- Roughly 15-30 commits per active hour is healthy; if you're at 60 you're committing noise; if you're at 3 you're not committing enough
- Commit messages: terse first line + bullet-list body + delete-path line at the bottom

### Reporting cadence: phase-boundary + finding-triggered

Update the session-log on these events:

- **Every phase boundary** — mark phase complete, advance status table
- **Every notable finding** — bench result, surprising behavior, dead end, design pivot. These go into the Findings section as you discover them, not at the end.
- **Every unilateral decision** — when you make a judgment call the user didn't pre-approve, append it to Decisions log with reasoning. Future-you reviewing the log should be able to reconstruct why.
- **Every cost-incurring call** — append to the cost ledger immediately, not at the end.

Do not update on a timer. Timer-based updates produce empty "still working" entries.

### Pre-flight checks (run before any Primary work begins)

- Run the test command detected during project scan (§1.1). Record baseline pass count in the session log. If detection is ambiguous (e.g. multiple plausible commands), pick the most obvious one and note the choice in the Decisions log.
- If TypeScript: `tsc --noEmit` after any refactor that touches shared types/signatures.
- Re-check `git status --porcelain` — must still be empty.

If the baseline tests don't pass, stop. Write the failures to the session log and exit cleanly — don't try to "work around" a broken baseline.

### Budget enforcement

- Track every API call's estimated cost in the ledger as it happens.
- Soft warn yourself at 80% — start preferring cheaper paths and skipping speculative spend.
- Hard stop at 100% — refuse further paid calls, complete current work without them, write final summary.
- Spend allocation guideline (not a hard rule): roughly 20% on Primary-phase validation, 80% reserved for variance-seeking and Stretch experiments. If you're hitting 100% on Primary alone, something's wrong with the plan.

### Forbidden tools (autonomous phase only)

Hard never:

- `AskUserQuestion`, `ExitPlanMode`, anything that blocks on user input
- `git push`, `git push --force`, `git reset --hard` past this run's first commit
- `gh pr create`, `gh issue create`, `gh release create`
- Skills that have interactive flows (you cannot fully predict them; assume risk and skip)
- Modifying the skill's own installation files

Allowed extensions: anything the user explicitly authorized at kickoff.

### Stopping criterion

The run ends when one of:

1. **The plan is complete *and* the variance-seeking self-check returns no more good ideas.** Required: before exiting on plan-complete, you must explicitly ask yourself *"are there benches I should run to try to break what I just built? Negative findings count. Are there Stretch ideas worth pursuing?"* If yes, keep working. Stop only when the honest answer is "no good ideas left."
2. **Budget hit hard stop.** Write final summary with what's done, exit.
3. **Availability window reached.** If the user said "8am" and it's 7:50am, wrap up. Same for "Monday morning" and it's Sunday 11pm.
4. **Catastrophic failure** the run can't recover from (test baseline broken, repo in unknown state, etc.). Write status to session log, exit.

### When to wrap

Wrap is its own ~10-minute phase. Don't merge it with the last work phase.

Wrap steps:

1. Final test/typecheck run. Record result.
2. Final commit if any uncommitted work (should not be any — atomic commits should have caught it).
3. Update session-log TL;DR section with one paragraph: what shipped + most important finding.
4. Fill in "For your review" with a punch list of 3-7 items, ordered by importance.
5. Fill in "Open questions" with anything you parked for the user.
6. Commit the session-log changes as the final commit.
7. List remaining safety-net wakes (if any are still scheduled past the availability window, leave a note but do not delete them; the user can clean up).

---

## Phase 3: Continuation (when a safety-net wake fires)

If a scheduled wake-up fires, you are a *resumed* agent, not the original. Read state before doing anything.

1. Read the session-log file referenced in the wake prompt. Note current status, what was completed, what was in progress, what's open. Note the *availability window* — has it passed?
2. Run `git log --oneline -30` to see commits since kickoff.
3. Run `git status --porcelain` to see uncommitted state.

Then decide one of:

- **Availability window has already closed** (user is theoretically back) → append an "arrival confirmed" entry, do not redo work, exit. The user will run the next session themselves.
- **Wrap was already done cleanly** (TL;DR filled, plan all marked complete, final commit present) → append an "arrival confirmed" entry, exit. Don't redo work.
- **Wrap did not happen and window is still open** → continue from where the prior session stopped. Same rules apply: atomic commits, no user prompts, budget cap, deletability constraint.
- **This is a day-arc boundary on a multi-day run** (user is still away, but ≥24h have elapsed since the last day-arc handoff was written) → write a day-arc handoff section to the session log first (mini-TL;DR + what changed today + what's queued for tomorrow), then continue.

You are still subject to all the hard rules. Specifically: you cannot ask the user any questions.

---

## A note on tone

The user is going to read the session log when they come back — possibly half-asleep, possibly between meetings, possibly with luggage at the door. Write for the time-pressed reader:

- **TL;DR is a *single paragraph*.** If they read nothing else, they read this.
- **Headings are scannable.** "Findings → Capability floor" is better than "Findings → Notes on cross-model bench behavior."
- **Lead with what shipped, follow with what was learned, end with what's open.**
- **No false humility, no false confidence.** State results plainly: "the bench validated X" or "the bench did not validate X" — not "the bench *seems* to suggest…" or "results were positive overall."
- **For multi-day runs:** keep the top-level TL;DR up to date as you go. Most-recent-first inside Findings. The user might skim only the newest day-arc handoff and the top of the doc.
