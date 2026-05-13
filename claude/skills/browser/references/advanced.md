# Advanced Browser Capabilities

Full details for features beyond basic navigation and interaction. Read whichever section applies to the task.

---

## File Downloads

Playwright can intercept file downloads before they hit the disk, or simply let them download and find the path afterward.

**Wait for a download triggered by a click:**
```js
// Via browser_run_code_unsafe:
const [download] = await Promise.all([
  page.waitForEvent('download'),
  page.click('text=Download CSV')
]);
const path = await download.path();   // temp path on disk
await download.saveAs('/home/fox/Downloads/file.csv');
console.log('Saved to', path);
```

**Set a default download directory** via MCP config (in `~/.claude/settings.json`):
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--browser", "firefox",
        "--save-downloads",          // enable download saving
        "--downloads-path", "/home/fox/Downloads"
      ]
    }
  }
}
```

---

## Full-Page Screenshots

`browser_take_screenshot` captures only the current viewport by default. For the full scrollable page:

```js
// Via browser_run_code_unsafe:
await page.screenshot({
  path: '/tmp/fullpage.png',
  fullPage: true
});
```

Or with `browser_evaluate` to scroll and stitch manually for very long pages.

The resulting file will be at the path you specified — tell the user where it is.

---

## Video Recording

Record the entire browser session as a WebM video file. Must be configured at browser context creation time — enable via MCP config or `browser_run_code_unsafe`.

**Via MCP config** (records all sessions):
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--video-dir", "/tmp/browser-videos"
      ]
    }
  }
}
```

Video files appear in the configured directory after the browser closes. File names are auto-generated UUIDs.

**Via browser_run_code_unsafe** (record a specific block):
```js
const context = await browser.newContext({
  recordVideo: { dir: '/tmp/videos/', size: { width: 1280, height: 720 } }
});
const page = await context.newPage();
// ... do things ...
await context.close();  // video is written on close
```

---

## Network Interception

Intercept, modify, or block network requests. Useful for mocking APIs, blocking ads/trackers, or inspecting what a page fetches.

**Block specific requests:**
```js
// Via browser_run_code_unsafe:
await page.route('**/*.{png,jpg,gif,webp}', route => route.abort());  // block images
await page.route('**/api/ads/**', route => route.abort());
```

**Mock an API response:**
```js
await page.route('**/api/user', route => route.fulfill({
  status: 200,
  contentType: 'application/json',
  body: JSON.stringify({ name: 'Test User', role: 'admin' })
}));
```

**Inspect requests:**
```js
page.on('request', req => console.log(req.method(), req.url()));
page.on('response', res => console.log(res.status(), res.url()));
```

Use `browser_network_intercept` if the MCP server exposes it directly, otherwise use `browser_run_code_unsafe`.

---

## PDF Export

Save the current page as a PDF (Chromium only — Firefox doesn't support this):

```js
// Via browser_run_code_unsafe:
await page.pdf({
  path: '/tmp/page.pdf',
  format: 'A4',
  printBackground: true,
  margin: { top: '1cm', bottom: '1cm', left: '1cm', right: '1cm' }
});
```

Switch to Chromium for this task if currently using Firefox. Update MCP config `--browser chromium --executable-path /usr/bin/chromium`.

---

## Storage & Cookies

**Read/write localStorage:**
```js
// Via browser_evaluate:
localStorage.getItem('key')
localStorage.setItem('key', 'value')
```

**Read/write sessionStorage:**
```js
sessionStorage.getItem('key')
sessionStorage.setItem('key', 'value')
```

**Export all cookies (save a session for later):**
Use `browser_cookies_get` if available, or:
```js
// Via browser_run_code_unsafe:
const cookies = await context.cookies();
require('fs').writeFileSync('/tmp/cookies.json', JSON.stringify(cookies, null, 2));
```

**Import cookies (restore a saved session):**
```js
const cookies = JSON.parse(require('fs').readFileSync('/tmp/cookies.json'));
await context.addCookies(cookies);
```

**Save full storage state** (cookies + localStorage — useful for resuming logged-in sessions):
```js
await context.storageState({ path: '/tmp/session.json' });
```

Load it next time via MCP config `--storage-state /tmp/session.json`.

---

## Browser Traces

Playwright traces record every action, screenshot, network request, and console message. Invaluable for debugging what went wrong.

**Start/stop tracing:**
Use `browser_trace_start` and `browser_trace_stop` if the MCP server exposes them, or:
```js
// Via browser_run_code_unsafe:
await context.tracing.start({ screenshots: true, snapshots: true });
// ... do things ...
await context.tracing.stop({ path: '/tmp/trace.zip' });
```

**View the trace:**
```bash
npx playwright show-trace /tmp/trace.zip
```
This opens the Playwright Trace Viewer in a browser window — a timeline of every action with before/after screenshots.

---

## Geolocation & Permissions

**Set a fake location:**
```js
// Via browser_run_code_unsafe:
await context.setGeolocation({ latitude: 35.6762, longitude: 139.6503 });  // Tokyo
await context.grantPermissions(['geolocation']);
```

**Grant or deny browser permissions:**
```js
await context.grantPermissions(['camera', 'microphone', 'notifications']);
await context.clearPermissions();
```

Via MCP config for persistent settings:
```json
{
  "args": ["@playwright/mcp@latest", "--geolocation", "35.6762,139.6503"]
}
```

---

## Multiple Browser Contexts (Isolated Sessions)

A browser context is like a fresh incognito window — separate cookies, storage, and session. Use multiple contexts to run two different logged-in accounts simultaneously, or test locale/region differences.

```js
// Via browser_run_code_unsafe:
const context1 = await browser.newContext();
const context2 = await browser.newContext({ locale: 'ja-JP', timezoneId: 'Asia/Tokyo' });

const page1 = await context1.newPage();
const page2 = await context2.newPage();

await page1.goto('https://example.com');  // logged in as user A
await page2.goto('https://example.com');  // fresh session for user B
```

Note: `@playwright/mcp` manages a single context by default. For multi-context workflows, use `browser_run_code_unsafe` to create additional contexts manually.
