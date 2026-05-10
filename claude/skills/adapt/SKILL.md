---
name: adapt
description: Session knowledge consolidation for Claude Code projects. Invoked via /adapt, this skill reviews the current session, compares what was learned against CLAUDE.md and docs/*.md, and proposes targeted additions, updates, or removals — keeping project memory lean, accurate, and human-readable. Use this skill whenever the user runs /adapt or asks Claude to update, sync, or capture session learnings into the project docs.
---

# /adapt — Session Knowledge Consolidation

Triggered when the user runs `/adapt` or asks Claude to capture, sync, or update project memory from this session.

Your job is to make the project smarter without making it bloated. Every change you propose must earn its place. When in doubt, leave it out.

---

## What you're managing

Two layers of project memory:

**`CLAUDE.md` (root)** — The lean index. Loaded every session, every context. Should contain:
- Project identity: what this is, what stack it uses
- Universal rules: things that apply to *every* task in this project
- Build/test/run commands Claude needs to do its job
- `@docs/filename.md` references to deeper knowledge

**`docs/*.md`** — The library. Human-readable reference docs, loaded on demand. Each file covers one coherent topic. Good examples: `architecture.md`, `decisions.md`, `workflows.md`, `gotchas.md`, `api-patterns.md`.

Both layers serve humans and Claude equally. Write them that way.

---

## The golden rules

**For CLAUDE.md:**
- Target ~60 lines. Hard ceiling: 100 lines.
- Every line must pass: *"Would removing this cause Claude to make mistakes on a typical task?"* If no, cut it.
- No code snippets — they go stale. Use `file:line` references instead.
- No style guidelines — Claude learns those from the codebase. Use a linter.
- No multi-step procedures — those belong in `docs/` or a skill.
- Prefer `@docs/filename.md` imports over inlining domain-specific knowledge.

**For `docs/*.md`:**
- One file per coherent topic. Don't create a file for a single fact.
- Write for a human developer reading it cold, not just for Claude.
- Prefer pointers to authoritative source files over copying content.
- Flat structure — no subdirectories unless the project is large enough to warrant it.

**For both:**
- Facts only. No explanatory prose, no padding.
- Specific and concrete. Vague guidance is worse than no guidance.
- When something is obsolete, flag it for removal — don't just add around it.

---

## Process

### Step 1: Read current state
Read `CLAUDE.md`. Then read any `docs/*.md` files that exist. Build a mental model of what the project currently knows.

### Step 2: Reflect on the session
Review what happened this session:
- What problems were solved?
- What patterns or conventions were established or discovered?
- What mistakes were made and corrected?
- What commands, file paths, or tool invocations proved important?
- What assumptions turned out to be wrong?
- What would have saved time if known at the start of this session?

### Step 3: Identify changes worth making
For each candidate change, ask:
- Is this universally applicable to this project, or only relevant to today's task?
- Is this already documented somewhere?
- Is this specific enough to actually guide future behavior?
- Will this still be true in a week?

If a piece of knowledge is task-specific, transient, or vague — skip it.

### Step 4: Propose changes as a diff
Present all proposed changes clearly before writing anything. Group them by file. Use this format:

```
## Proposed changes

### CLAUDE.md
ADD (line ~12, under "Workflows"):
  - Always run `npm run typecheck` before committing

REMOVE (line 34):
  - "Use camelCase for all variables" — enforced by ESLint, not needed here

### docs/gotchas.md (new file)
CREATE with the following content:
  [show full proposed content]

### docs/architecture.md
UPDATE "Auth section":
  [show before and after]
```

Then ask: **"Does this look right? Anything to add, change, or skip?"**

### Step 5: Write on approval
Only write files after the user confirms. Apply exactly what was approved — nothing more.

If the user approves with modifications, incorporate their changes before writing.

### Step 6: Do nothing if there's nothing worth capturing
If the session produced nothing new — routine tasks, no surprises, no corrections — say so briefly:

> "Nothing from this session that needed capturing. Project docs are already up to date."

Don't invent changes to justify running.

---

## What belongs where — quick reference

| Knowledge type | CLAUDE.md | docs/*.md | Skill | Neither |
|---|---|---|---|---|
| Build/test commands | ✓ | | | |
| Project stack & structure | ✓ (brief) | ✓ (detailed) | | |
| Universal coding conventions | ✓ (1 line) | | | |
| Code style / formatting | | | | ✓ (use linter) |
| Architecture decisions | `@docs/` ref | ✓ | | |
| Recurring workflows | `@docs/` ref | ✓ | Consider skill | |
| Gotchas & non-obvious facts | | ✓ | | |
| Task-specific instructions | | | ✓ | |
| Temporary notes | | | | ✓ |

---

## Tone and style for generated docs

Write like a senior dev leaving notes for their future self or a new teammate:
- Terse, factual, confident
- Present tense: "Auth uses JWT, not sessions" not "Auth was changed to use JWT"
- No filler: "Note that..." / "It's important to..." / "Make sure to..." — cut these
- Headers in `docs/*.md` should be descriptive nouns: "Auth Flow", "Database Conventions", not "How Auth Works" or "Things to Know About the Database"

---

## Example: CLAUDE.md structure to aim for

```markdown
# ProjectName

TypeScript monorepo. Node 20. pnpm workspaces.

## Structure
- `apps/api` — Express REST API
- `apps/web` — Next.js frontend
- `packages/shared` — shared types and utils

## Commands
- `pnpm test` — run all tests
- `pnpm typecheck` — typecheck all packages
- `pnpm build` — production build

## Rules
- Never commit directly to main
- All API routes need input validation via zod

## Reference
- Architecture: @docs/architecture.md
- Auth flow: @docs/auth.md
- Known gotchas: @docs/gotchas.md
```

This is ~20 lines. It covers WHAT, HOW, and WHERE. Everything else lives in `docs/`.
