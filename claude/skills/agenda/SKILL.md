---
name: agenda
description: "Work through a conversation with several open threads one at a time, tracked in a root AGENDA.md that survives a context clear. Invoke whenever there are two or more open threads — questions Claude raised, or points the user raised about a block of output — and whenever the user says /agenda, 'add to the list', 'walk me through this', 'what's left', or asks to go point by point. Also invoke when a root AGENDA.md exists and work is resuming."
---

# Agenda Skill

A long answer with five open questions is harder to handle than a long answer with one. The problem is never the word count — it is the number of threads needing a reply, because answering all of them at once turns two open threads into nine.

This skill keeps those threads in `AGENDA.md` at the repo root and walks them **one at a time, to completion, in arbitrary depth**, without losing what is left.

## The rule that does the work

> **Park, don't fan out.**

While an item is open, a new question that arises goes **on the list**. It is not asked. Only the open item is discussed.

This holds whether or not an agenda file exists. Everything below is the mechanism.

## When to open one

**Two or more open threads**, from either side:

| Source | Example |
|---|---|
| Claude's own | A design response ending in four decisions |
| The user's | A reply raising three points about one block of output |
| A block itself | "walk me through this" — sections become items, no disagreement needed |

Open it automatically; the user can decline in a word. One thread is a conversation, not an agenda — don't impose structure that isn't earned.

## Splitting the user's message

The user writes the natural multi-part reply. **Do not answer all of it.** Split it into items, **show the split**, and take the first:

> Reading that as three: (1) where the file lives, (2) the position marker, (3) whether closed items are kept. Starting with 1 — say the word if that's a bad split.

The split is a judgment call and will sometimes be wrong — two of the points are really one thought. Showing it costs a line and makes it correctable; splitting silently is worse than not splitting.

**`AskUserQuestion` is not the mechanism.** It fits an item that is a genuine
two-to-four-option decision, and nothing else — the user's standing preference is
prose lists over menus, with the tool reserved for real either/or choices. Most
agenda items are open-ended discussion and get discussed.

Not everything is an item. Only things needing resolution — "that makes sense, and what about X" is one item, not two.

## `AGENDA.md`

Root of the repo, so it is noticed and so a **cold session can resume from it**. Globally gitignored (`~/.gitignore`), which also keeps it out of `/wrap`'s commit.

Each open item must be self-contained enough to reconstruct without the conversation, and each closed item must record its **resolution** — that is what stops a fresh session re-litigating a settled question.

```markdown
# Agenda — <topic in a few words>

**Position:** 2 of 5

## Open

### 2. Where the agenda file lives  ← current
Root rather than tmp/, so it is noticed and survives a context clear.
Open: how to keep /wrap from committing it.

### 3. <next item>
<enough that a cold session knows what this is>

## Closed

### 1. Trigger threshold
**Resolved:** two or more open threads, from either side. Automatic, one-word decline.
```

If the repo root already has an `AGENDA.md`, a walk is in progress — read it and resume rather than starting a new one.

## Walking it

1. Open exactly one item at a time.
2. Sub-points nest under the current item. Depth is unlimited; the one-at-a-time rule still applies at every level.
3. **Close explicitly**, recording the resolution in a line. Then state what remains and open the next.
4. **One answer can close several items** — resolving item 1 sometimes makes item 4 moot. Say so and mark it, rather than walking to a dead question.
5. The user may jump the queue. Default order is the order things were raised.

Carry a position marker as a footer while a walk is open:

```
*Agenda: 2 of 5 — where the file lives*
```

On closing an item, show the remaining list in full rather than the marker alone.

## Other entry points

- **"add to the list: …"** — appends an item that isn't a reply to anything.
- **"walk me through this"** — turns a block of output into an agenda with no disagreement involved.
- **"what's left"** — print the open items.

## Closing out

**The agenda is scaffolding, not a record.** When the last item closes, anything durable — a decision, a design, a rule — gets filed into the project's real docs, `TODO.md`, or memory, exactly as it would have been anyway. Then **delete `AGENDA.md`**.

A stale agenda in the repo root is worse than none: the next session reads it as open work.
