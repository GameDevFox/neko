# Global Claude Instructions

## Code Style

**JavaScript / TypeScript:** Use arrow functions; avoid the `function` keyword.

**Classes:** Avoid `class`, `constructor`, `extends`, `super`, `new` (for user-defined types), and `this`. Use factory functions instead:

```ts
export type Foo<T> = { ... };
export const Foo = <T>(...args): Foo<T> => ({ ... });
```

Share behavior by importing functions, not via inheritance. Always end TypeScript statements with semicolons.

**Magic numbers:** Avoid unexplained numeric (or string) literals in logic, layout, and math. Extract them to named constants — at the top of the file, or a shared `constants`/`config` module when reused — with names (or a brief comment) that say what the value *means*, e.g. `const SNAP_THRESHOLD_PX = 8;` not `if (d < 8)`. Trivially self-evident values (`0`, `1`, `-1`, `2` in obvious arithmetic, identity/unit values) don't need names. When tuning a value in place, still land it as a named constant.

## Approach

**Prior art before an abstraction.** A general mechanism — a utility, a scheduler, a caching layer — gets a prior-art check before it gets designed: name the pattern, find who has already solved it, and say plainly whether to borrow or build. *"Nothing fits, and here is why"* is a wanted answer, not a failure to find one. A one-off fix needs none of this.

**Simplest implementation first.** Ship the smallest version that is genuinely useful and record the rest as follow-ons. Decide what to defer *before* starting, not after.

**File a settled idea where it belongs, immediately.** An idea handed over in conversation — a mechanic, a design tweak, a piece of lore — goes into the project's existing structure in the same turn, matching the conventions of its neighbours. Don't park it in a scratch file, don't leave it in chat, and don't ask where it goes when the structure already answers that. An open thread still under discussion is different: that one is parked on the agenda and filed when it resolves.

## Memory Files

**Never use `@path` in a CLAUDE.md unless explicitly asked.** `@` is an *import*, not a pointer: it inlines the whole file eagerly at session start. neko-agent's 102-line CLAUDE.md was pulling in 1.2 MB across 41 files this way — roughly 304k tokens spent before the first prompt. Reference docs by plain path so they are read only when the task needs them.

**A lesson that isn't about this codebase belongs in the global file, not project memory.** The machine, the shell, the harness, or a preference stated out loud — those recur in every project, and memory is scoped to one. Propose the promotion rather than filing it locally. The filter is the failure mode: promote what fails **silently or destructively**; something loud that costs one retry stays in memory.

**A promoted rule gets its own bullet, and its source memory gets a line pointing at the new home.** A clause folded into an existing rule is absorbed by the next rewrite of its host — that is how one escalation evaporated for a fortnight while the memory went on asserting it had landed. Grep before believing a memory's claim that something was escalated.

## Testing

Write tests first when practical. Only test non-trivial behaviors — skip obvious pass-throughs and things that can't actually break.

**A passing test is not evidence until you have watched it fail.** Mutate the line it covers and re-run. Five tests written in one day each passed for a different wrong reason — wrong layer, wrong timescale, a guard that never fired, a double that bypassed the code — and mutation caught all five where review caught none.

**Mutate the wiring, not only the logic.** A pure function with thorough tests that nothing actually calls leaves the suite green when you delete the call site. A zero-red mutation is itself the finding.

**Run tests from the repo root, scoped with the package manager's filter flag** (`pnpm --filter <pkg>`, `yarn workspace <pkg>`) rather than by `cd`-ing into a package. A `cd` persists into the next Bash call, so a later root-level test command runs that package alone and reports a clean pass that reads as the whole suite.

## Communication

The user often interacts via voice-to-text. If a message contains words or phrases that seem out of place or oddly phrased, assume it's a speech-to-text mistranslation and try to infer the most likely intent. Don't flag minor quirks.

**Brainstorm in prose, not menus.** For idea generation — names, design directions, candidates — write the full list in the response, grouped, with one-line rationales. `AskUserQuestion` caps the option space at four or five exactly when breadth is the point; save it for genuine few-option decisions.

## One Thing at a Time

When a conversation has **two or more open threads** — questions I've raised, or points you've raised about a block of output — work them one at a time rather than answering everything at once.

**Park, don't fan out.** A new question arising while an item is open goes on the list; it is not asked yet. Answering every branch at once is what turns two open threads into nine, and the cascade starts on my side, not yours.

That applies to your messages too: a reply raising three points gets **split into three items**, with the split shown so you can correct it — never answered in one go. You should not have to change how you write.

An `AGENDA.md` in the repo root means a walk is already in progress — read it before responding. The `/agenda` skill owns the rest of the mechanism; the rule above holds whether or not an agenda is open.

## Git

Never stage, commit, push, or perform any other git write operation unless explicitly asked. This includes "helpful" proactive commits after completing a task — do not commit unless the user asks for it directly.

**Don't raise branch strategy, merging, or how many commits have accumulated.** Version control runs on the user's schedule. Report tests, lint, and whether the tree is clean, and stop there. If something genuinely depends on a merge having happened, say what depends on it once rather than repeatedly.

## Shell & Editing

**Never `git checkout`/`restore` to undo your own edit** — a patch that came out wrong, a mutation test to revert. It restores the file to HEAD and discards every *other* uncommitted change in it: it has silently deleted finished work three times in one session, and the suite went green because the tests for the lost code went with it. Undo with an inverse edit, or ask to commit first. Then grep for a symbol that should have survived — `git status` showing the file modified proves nothing.

**Never anchor an edit on a pattern you haven't counted.** `replace(old, new, 1)` and regex insertion both take the *first* match, so a pattern appearing three times lands the edit in the wrong place; and `.replace()` returns the string unchanged when the pattern is absent at all — no error, no diff, no signal. One check covers both: assert the pattern occurs **exactly once** before editing (`t.count(old) == 1`, `grep -c`), or anchor on line numbers you have just read. The wrong-site half has gone wrong in six distinct shapes.

## Service Windows

When running inside a tmux session, the Claude Code session is always the first window. Services a project needs (backend, frontend, etc.) each get their own named window in the same session, named for the service — `server`, `api`, `client`, `webapp`. The project's `CLAUDE.md` says which windows to create and what to run in them.

The session name matches the project directory by convention; `tmux display-message -p '#S'` confirms it from inside.
