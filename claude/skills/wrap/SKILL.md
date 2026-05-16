---
name: wrap
description: End-of-session wrap-up for Claude Code projects. Invoked via /wrap. Updates CLAUDE.md and docs/*.md with session learnings, reconciles TODO.md (removes previously-committed completions, marks newly-completed items), then stages all session changes and commits with user approval. Use this skill whenever the user runs /wrap or asks to wrap up, close out, or finish the session.
---

# /wrap — Session Wrap-Up

Triggered when the user runs `/wrap` or asks to wrap up or close out the session.

Three phases, run in order: **docs**, **TODO**, **commit**. Complete all three before asking for a single approval.

---

## Phase 1: Doc Updates

Update project memory so the next session starts smarter.

### What you're managing

**`CLAUDE.md` (root)** — Lean index. Loaded every session. Should contain:
- Project identity: what this is, what stack it uses
- Universal rules: things that apply to *every* task
- Build/test/run commands
- `@docs/filename.md` references to deeper knowledge

**`docs/*.md`** — The library. Human-readable reference docs, loaded on demand. One file per coherent topic.

### Golden rules

**For CLAUDE.md:**
- Target ~60 lines. Hard ceiling: 100 lines.
- Every line must pass: *"Would removing this cause Claude to make mistakes on a typical task?"* If no, cut it.
- No code snippets — use `file:line` references instead.
- No style guidelines — use a linter.
- No multi-step procedures — those go in `docs/` or a skill.

**For `docs/*.md`:**
- One file per coherent topic. Don't create a file for a single fact.
- Write for a human developer reading cold, not just for Claude.
- Prefer pointers to source files over copying content.

**For both:**
- Facts only. No padding.
- Specific and concrete. Vague guidance is worse than none.
- When something is obsolete, flag it for removal.

### Reflection checklist

Review the session:
- What problems were solved?
- What patterns or conventions were established or discovered?
- What mistakes were made and corrected?
- What commands, file paths, or tool invocations proved important?
- What would have saved time if known at the start?

Only capture what is universally applicable, specific, and will still be true in a week.

### What belongs where

| Knowledge type | CLAUDE.md | docs/*.md | Neither |
|---|---|---|---|
| Build/test commands | ✓ | | |
| Project stack & structure | ✓ (brief) | ✓ (detailed) | |
| Universal coding conventions | ✓ (1 line) | | |
| Code style / formatting | | | ✓ (use linter) |
| Architecture decisions | `@docs/` ref | ✓ | |
| Gotchas & non-obvious facts | | ✓ | |
| Task-specific instructions | | | ✓ |

---

## Phase 2: TODO Reconciliation

Read `TODO.md`. Then do two things in order.

### Step 1: Remove all completed items

Delete every line marked `- [x]` from the file — regardless of when it was checked off. These items were already recorded in a prior commit and are safe to remove. The commit history is the archive.

### Step 2: Mark newly completed items

Based on the work done this session, identify which remaining `- [ ]` items were fully completed. Mark them `- [x]`. Do not mark items partially done or only touched — only things genuinely finished this session.

Infer completions from context: what was built, fixed, or closed during the session. Do not ask the user to enumerate them — figure it out from the conversation.

---

## Phase 3: Commit

### Step 1: Identify files to stage

Default: **stage everything not yet committed.** The wrap commits one coherent picture of the session — code, docs, tests, and tracking together.

Before staging, run `git status` and scan for changes that look unrelated to the session's work (e.g. a half-finished refactor in an unrelated directory, dependency lockfile churn from an aborted experiment). For each one, **check with the user**: "I see X is also modified — looks unrelated to this session's work. Include it in the wrap commit, or leave it for you to handle?" Default is to include unless the user says otherwise.

The only things to leave out without asking:
- Files that should be gitignored (build artifacts, local state, env files). If you spot one, propose adding it to `.gitignore` as part of the wrap.
- Untracked files that are obviously transient (temp scripts, scratch outputs).

### Step 2: Draft commit message

Short summary of what the *session* accomplished. Match the repo's existing commit style — run `git log --oneline -10` to see the convention. Most repos use a `<topic>: <description>` shape (e.g. `auth:`, `config:`, `history:`).

**Do not use a `Wrap:` prefix.** The fact that this commit was created by the wrap skill is not a useful classifier in `git log`. Describe the work, not the tool.

Examples:
- `auth: add JWT refresh flow + middleware`
- `payments: refactor service, update architecture docs`
- `init: initial project setup`

### Step 3: Present for approval

Show everything before touching git:

```
## Wrap-up summary

### CLAUDE.md
[ADD / REMOVE / UPDATE with before/after for each change, or "No changes"]

### docs/<file>.md
[Changes or "No changes"]

### TODO.md
Removed (already in version control):
  - [x] item one
  - [x] item two

Newly marked complete:
  - [x] item three

### Commit
Files to stage: <list everything, or "all pending changes (N files)">
Unrelated changes flagged: <list with question, or "none">
Message: "<summary>"

Does this look right? Anything to change before committing?
```

### Step 4: Write and commit on approval

Only after the user confirms:
1. Apply all doc changes (CLAUDE.md, docs/*.md, TODO.md)
2. Stage the files (prefer naming them explicitly rather than `git add -A`/`git add .` to avoid accidentally including sensitive files)
3. Run `git diff --cached --stat` and verify only the intended files are listed — pre-staged renames or partial `git add -p` selections can sneak in
4. Commit with the agreed message

If the user requests changes to the proposed diff or message, incorporate them first.

**Never commit without explicit user approval.**

### Step 5: Nothing to wrap

If `git status` shows no pending changes after Phase 1 and Phase 2 have run (i.e. no uncommitted work in the tree at all):

> "Nothing to wrap — docs are up to date and no TODO items changed."

Don't invent changes to justify running.

---

## Tone for generated docs

Write like a senior dev leaving notes for their future self:
- Terse, factual, confident
- Present tense: "Auth uses JWT, not sessions"
- No filler: cut "Note that...", "Make sure to...", "It's important to..."
- Headers in `docs/*.md` should be descriptive nouns: "Auth Flow", not "How Auth Works"
