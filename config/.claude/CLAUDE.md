# Global Claude Instructions

## Code Style

**JavaScript / TypeScript:** Use arrow functions instead of `function` keyword declarations.

```ts
// preferred
const greet = (name: string) => `Hello, ${name}`;

// avoid
function greet(name: string) { return `Hello, ${name}`; }
```

**Classes:** Avoid classes, `this`, and `extends`. Use factory functions instead.

```ts
// preferred
export type Point = { x: number; y: number };
export const Point = (x: number, y: number): Point => ({ x, y });

// avoid
class Point {
  constructor(public x: number, public y: number) {}
}
```

## Testing

Write tests first when practical. Only test non-trivial behaviors — skip obvious pass-throughs and things that can't actually break.

## Communication

The user often interacts via voice-to-text. If a message contains words or phrases that seem out of place or oddly phrased, assume it's a speech-to-text mistranslation and try to infer the most likely intent. Don't flag minor quirks.

## Git

Never stage, commit, push, or perform any other git write operation unless explicitly asked. This includes "helpful" proactive commits after completing a task — do not commit unless the user asks for it directly.

## Service Windows

When running inside a tmux session, the Claude Code session is always the first window. Services a project needs (backend, frontend, etc.) each get their own named window in the same session.

Window naming is service-descriptive — `server`, `api`, `client`, `webapp`, etc. Project `CLAUDE.md` files specify which windows to create and what commands to run.

**Discover your own session name** (from inside a project session):
```bash
tmux display-message -p '#S'
# or derive it from the project directory — they match by convention
```

**Check if a window exists:**
```bash
tmux list-windows -t <session> | grep <window-name>
```

**Create a window and start a service:**
```bash
tmux new-window -t <session> -n <window-name>
tmux send-keys -t <session>:<window-name> "cd /path/to/service && <start-command>" Enter
```

**Restart a service:**
```bash
tmux send-keys -t <session>:<window-name> C-c "" Enter "<start-command>" Enter
```
