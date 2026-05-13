---
name: browser
description: >
  ALWAYS use this skill when the user wants you to actually operate a real browser — not just fetch or search the web, but physically navigate, click, type, screenshot, or interact with a live page. This includes: opening a URL in a browser window, clicking buttons or links, filling and submitting forms, logging into sites, taking screenshots of rendered pages, scraping content that requires JS to load, automating multi-step web flows, and setting up or troubleshooting Playwright MCP / browser automation. Key trigger phrases: "go to", "open", "browse to", "visit", "click", "fill in", "log into", "take a screenshot of", "check the page", "grab from [site]", "set up browser automation". Do NOT use for general web searches (use WebSearch), fetching raw file URLs (use WebFetch), or questions about browser technology — only when the task requires a real running browser controlled by Claude.
---

# Browser Automation

You control a real browser via the Playwright MCP server (`@playwright/mcp`). This gives you ~50 tools to navigate, interact with, and read web pages — the same capabilities a human has on their desktop.

---

## Do you actually need a browser?

Before reaching for browser tools, ask: does this task require real browser interaction?

**Use WebFetch or WebSearch instead** when the task is just reading public content — headlines, article text, documentation, public GitHub profiles, etc. These are faster, cheaper, and don't require any setup.

**You need the browser** when the task involves:
- Clicking, filling forms, submitting, dragging
- Logging in or navigating behind authentication
- JavaScript-heavy SPAs where content isn't in the raw HTML
- Taking a screenshot of the rendered page
- Anything interactive

If browser tools aren't available and the task genuinely needs them, follow the Setup section below.

---

## Quick fallback: one-off screenshot without MCP

If browser tools aren't configured yet and all you need is a screenshot of a public page, use the system Chromium CLI — no setup required:

```bash
chromium --headless=new --screenshot=/tmp/screenshot.png --window-size=1280,900 https://example.com
```

Tell the user where the file was saved. This is a stopgap — for interactive tasks, you'll need the full MCP setup below.

---

## Setup (when browser tools are needed but not available)

If `browser_*` tools aren't in your toolset and the task genuinely requires them, run setup now — don't ask the user to do it manually.

### Step 1: Check what's already installed

```bash
which node firefox chromium
```

Skip any step below for tools that are already present.

### Step 2: Install missing dependencies

```bash
# Arch Linux — install what's missing:
sudo pacman -S --noconfirm nodejs npm   # if node is absent
sudo pacman -S --noconfirm firefox      # preferred: avoids bundled binary conflicts on Arch

# macOS:
brew install node   # if node is absent
# Firefox or Chrome: Playwright can download its own browser on macOS — skip this

# Windows: install Node from nodejs.org if absent
```

### Step 3: Register the MCP server

```bash
claude mcp add playwright npx @playwright/mcp@latest --browser firefox
```

Verify it registered:
```bash
claude mcp list
```

### Step 4: Restart Claude Code

Tell the user: *"I've set up the browser tools. Restart Claude Code and come back — the `browser_*` tools will be available and I'll pick up right where we left off."*

After restart, confirm `browser_navigate` appears in your available tools before proceeding.

---

## How to Use the Browser

### The mental model: accessibility tree first, screenshots as fallback

The primary way to understand a page is `browser_snapshot` — it returns the page's accessibility tree (ARIA roles, labels, text, element IDs). Each interactive element gets a reference ID like `e45`. Use that ID in subsequent actions:

```
browser_snapshot → see element ref="e45" "Submit button"
browser_click(element="Submit button", ref="e45")
```

This is more reliable than guessing coordinates. Screenshots exist but are for visual verification, not navigation.

### Core workflow

1. **Navigate**: `browser_navigate(url="https://example.com")`
2. **Understand the page**: `browser_snapshot()` — read the accessibility tree
3. **Interact**: click, type, fill, hover, drag using element refs from the snapshot
4. **Verify**: `browser_take_screenshot()` if you want to visually confirm state
5. **Repeat** for multi-step flows

### Key tools and when to use them

| Tool | When |
|---|---|
| `browser_navigate` | Go to a URL |
| `browser_snapshot` | Read the page — do this before any interaction |
| `browser_click` | Click a link, button, checkbox, etc. |
| `browser_type` | Type into a focused input (character by character, fires events) |
| `browser_fill` | Set an input's value directly (faster, good for forms) |
| `browser_select_option` | Select from a `<select>` dropdown |
| `browser_hover` | Hover to reveal menus or tooltips |
| `browser_drag` | Drag one element to another |
| `browser_file_upload` | Upload a file to a file input |
| `browser_take_screenshot` | Visual snapshot of current page state |
| `browser_tab_new` | Open a new tab |
| `browser_tab_list` | See all open tabs |
| `browser_tab_select` | Switch to a tab |
| `browser_go_back` / `browser_go_forward` | Browser history navigation |
| `browser_reload` | Refresh the page |
| `browser_evaluate` | Run JavaScript in the page context |
| `browser_run_code_unsafe` | Run arbitrary Playwright JS — for complex scenarios |
| `browser_wait_for` | Wait for an element or condition to appear |

### Handling dynamic content (SPAs, infinite scroll, modals)

SPAs update the DOM asynchronously. After any navigation or interaction that might load new content:
- Call `browser_snapshot` again — it reflects current rendered state
- If something isn't visible yet, use `browser_wait_for` before trying to interact

For infinite scroll or lazy-loaded content:
```js
// Via browser_evaluate:
window.scrollTo(0, document.body.scrollHeight)
```
Then snapshot again.

### Working together — when to pause and ask for help

The headed browser is a shared workspace: the user can see the same window you're controlling. Use this. Whenever you're stuck, uncertain, or need something only a human can provide, pause and describe what you see, then ask them to step in. Don't try to guess or work around things silently.

**Always pause and ask the user to take over when:**
- A login form appears — ask them to enter their credentials directly in the browser window, then tell you when they're done
- A CAPTCHA appears — ask them to solve it in the window
- 2FA / MFA is required — ask them to complete it
- A consent dialog, cookie banner, or terms-of-service gate requires a decision
- The page looks unexpected or you're unsure how to proceed
- You've tried something twice and it isn't working

**How to hand off:**
Say something like: *"I see a login form. Please go to the Firefox window and enter your credentials, then come back here and tell me when you're done."* Wait for them to confirm before continuing.

After they hand back control, take a fresh `browser_snapshot` to see the current state before proceeding.

### Login flows

Most login flows are: navigate → fill username → fill password → click submit → wait for redirect → snapshot to confirm.

Never fill in passwords yourself unless the user explicitly pastes credentials into the conversation. For any site requiring authentication, pause and ask the user to log in directly in the browser window.

### When accessibility tree is broken or missing

Some sites deliberately hide or mangle accessibility structure. If `browser_snapshot` returns empty or useless content:
1. Take a screenshot and examine it visually
2. Try `browser_evaluate("document.body.innerText")` to get raw text
3. Use `browser_run_code_unsafe` to inspect the DOM directly
4. Fall back to clicking by position via `browser_evaluate("document.querySelector('...').click()")`

### Headed mode (visible browser window)

By default, a Firefox window will appear on your desktop as the browser operates. This is intentional — you can watch what's happening and intervene if needed. Don't close it manually while automation is running.

If you need headless (no visible window), add `--headless` to the MCP server args in settings.json.

### Connecting to your existing browser session

If you're already logged into sites and don't want to log in again, use Browser MCP instead — it's a Chrome extension that lets Claude control your real running Chrome session with all your existing cookies. Install from `browsermcp.io` and run `npx @browsermcp/mcp` instead of the Playwright server.

---

## Common Patterns

### Scrape content from a page

```
browser_navigate(url="...")
browser_snapshot()           # read the structure
browser_evaluate("document.querySelector('main').innerText")  # extract text
```

### Fill and submit a form

```
browser_navigate(url="...")
browser_snapshot()
browser_fill(element="Email", ref="e12", value="user@example.com")
browser_fill(element="Password", ref="e13", value="...")
browser_click(element="Sign in", ref="e14")
browser_snapshot()           # confirm logged in
```

### Open multiple tabs and compare

```
browser_navigate(url="https://site-a.com")
browser_tab_new(url="https://site-b.com")
browser_tab_select(index=0)  # back to first tab
```

### Run JavaScript in the page

```
browser_evaluate("window.location.href")        # current URL
browser_evaluate("document.title")              # page title
browser_evaluate("localStorage.getItem('key')") # read storage
```

---

## Advanced Capabilities

Playwright MCP supports more than basic navigation and clicking. If the user's task involves any of the following, read `references/advanced.md` for full details:

- **File downloads** — intercept and save files the browser downloads
- **Full-page screenshots** — capture the entire scrollable page, not just the viewport
- **Video recording** — record a browser session as a video file
- **Network interception** — mock or block specific requests, inspect traffic
- **PDF export** — save a page as a PDF
- **Storage & cookies** — read/write localStorage, sessionStorage, cookies across sessions
- **Browser traces** — record a Playwright trace for debugging (viewable in Playwright Trace Viewer)
- **Geolocation & permissions** — set fake location, grant/deny browser permissions
- **Multiple browser contexts** — run isolated sessions simultaneously (different logins, locales)

---

## Troubleshooting

**`browser_*` tools not available after restart** — check `claude mcp list` to confirm the server is registered. If not, re-run the add command or manually verify `~/.claude.json`.

**Firefox fails to launch on Arch** — ensure `firefox` is installed (`which firefox`). Try adding `--no-sandbox` to the browser launch args if running as root.

**Page content looks wrong or incomplete** — always call `browser_snapshot` after navigation, not before. SPAs need a moment; use `browser_wait_for` if elements are slow to appear.

**Can't interact with an element** — verify the ref ID from the most recent snapshot (refs change after page updates). Take a screenshot to see the current visual state.

**Site blocks automation** — some sites detect headless/automated browsers. Try using Browser MCP (your real Chrome session) instead, or Browserbase for residential proxy support.
