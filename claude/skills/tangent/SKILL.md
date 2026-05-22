---
name: tangent
description: "Save and restore conversation context across nested tangents. Use /tangent to checkpoint where you are before going on a detour, and /tangent pop to return. Invoke /tangent whenever the user is about to go off-topic, wants to preserve current progress, or explicitly says /tangent. Invoke /tangent pop when the user wants to end the current tangent and return to what they were doing before."
---

# Tangent Skill

Conversations branch. This skill maintains a stack of **checkpoints** in `.claude/tangents.md` so you can dive into a tangent and resurface cleanly — even from a completely fresh session with no conversation history.

The checkpoint is the key artifact. It must be self-contained enough that a new Claude session can read it cold and resume work without needing the original conversation.

## Commands

| Invocation | Effect |
|---|---|
| `/tangent` | Save a checkpoint of the current context, push onto the stack |
| `/tangent pop` | Pop the top checkpoint, reorient and reinject context |

## `/tangent` — Creating a checkpoint

Synthesize the current conversation into a structured checkpoint and append it to `.claude/tangents.md`.

A good checkpoint covers everything a cold-start session would need:

```markdown
## [N] <short descriptive title inferred from context>
**Saved:** YYYY-MM-DD

### What we're doing
One or two sentences: the goal and why it matters right now.

### Current state
Bullet list of what's already been built, decided, or implemented. Be specific — name files, functions, patterns.

### Next step
The single most immediate action to take when resuming. Concrete enough to act on without re-reading the whole conversation.

### Key decisions & constraints
Decisions made during this work that would take time to re-derive from the code alone. Include the reasoning if it was non-obvious.

### Relevant files
File paths Claude should re-read when resuming to restore its understanding.
```

After writing the checkpoint, confirm briefly: "Checkpoint saved: [title]. Use `/tangent pop` to return here."

**If the file doesn't exist yet**, create it with the header `# Tangent Stack` before the first entry.

**Nesting is supported** — each `/tangent` call pushes a new entry. Depth 0 is the original context; higher numbers are deeper tangents.

## `/tangent pop` — Returning to a checkpoint

1. Read `.claude/tangents.md`
2. Identify the top entry (highest `[N]`) — **this is the context you are resuming**
3. Remove that top entry from the file and write it back
4. **Actively reorient to the entry you just popped** — not to whatever remains on the stack. Re-engage with it as a live briefing:
   - Summarize what we were doing and why in 2–3 sentences
   - State the next step clearly
   - Re-read any files listed under "Relevant files" so they're fresh in context
5. Confirm: "Back to: [title] — [one-line next step]."

**Important:** You resume the popped entry ([N]), not the one below it ([N-1]). The stack shrinks so the *next* pop will go one level deeper. Think of it as: "load this checkpoint into the conversation, then discard it since we're now live in it."

The restatement and file re-reads are the reinjection. They bring the checkpoint's information forward in the context window, where it has more weight in attention. This is what makes the pop actually restore working state rather than just recalling a label.

**If the stack is empty**, say: "Stack is empty — nothing to pop."

## Stack file format

```markdown
# Tangent Stack

## [0] Original task title
**Saved:** 2026-05-21

### What we're doing
...

### Current state
...

### Next step
...

### Key decisions & constraints
...

### Relevant files
...

## [1] First tangent title
**Saved:** 2026-05-21
...
```

Rules:
- `# Tangent Stack` header is always present
- Entries are numbered from 0 (bottom/oldest) upward; highest index is current
- On `push`: append a new entry at the end
- On `pop`: read the top entry, reorient to it, then remove it and re-write the file — you resume what was at the top, not what's left beneath it
- Always read the file before writing — it's the source of truth, not in-memory state
