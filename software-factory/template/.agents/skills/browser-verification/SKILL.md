---
name: browser-verification
description: Use whenever a change can be seen in a browser - before claiming a UI slice done, when reproducing a UI bug, and when the orchestrator re-verifies a builder's work. Drives the real running app with browser-use and records the evidence. This project does not use Playwright, Puppeteer, Cypress or Selenium.
---

# Browser verification

"The tests pass" is not "the feature works". A person opening the app is the real test, so do what they would do, in a real browser, and keep the recording.

**One browser tool: `browser-use`.** It drives Chrome over CDP through the accessibility tree, which is how a user perceives the page. Do not add Playwright, Puppeteer, Cypress or Selenium to the project, and do not run them through `npx` or `uvx`. One tool means every agent's evidence looks the same and no browser binaries land in the image. Read the `browser-use` skill for the API. Install: `uv tool install --python 3.12 browser-use`; diagnose: `browser-use --doctor`.

## Procedure

1. **Write the assertions first**, from the ticket's Goal and Done means, each as something a user would observe: "after saving, the contact appears at the top of the list". If you cannot state it that way, it is not a browser check.
2. **Start the app**: `make up`, then `make url` (`docker-dev`).
3. **Own your browser session.** Several agents share one machine: `export BU_NAME=<ISSUE-KEY>` so you get your own daemon. Open one tab with `new_tab(url)` and keep it. Never touch tabs you did not open.
4. **Record**: `start_recording("<ISSUE-KEY>", title="...")`. Keep the directory it returns.
5. **Drive it like a user.** Find elements through the accessibility tree by role and name, not CSS selectors or injected JavaScript. If an element cannot be found by role and name, a screen-reader user cannot find it either: report that as an accessibility finding.
6. **Assert on what the page shows**: visible text, element state, the URL. Take a `capture_screenshot(path)` at each assertion. Include one unhappy path: bad input, empty state, or a second tenant's id (`tenant-scoping`).
7. `stop_recording()`. Copy the recording and screenshots to `.artifacts/<ISSUE-KEY>/`. That folder is gitignored; evidence is uploaded, never committed.
8. **Report**, in `thoughts/runs/<ISSUE-KEY>-report.md` under Verification:

   ```markdown
   | # | Assertion | Result | Evidence |
   |---|---|---|---|
   | 1 | Saved contact appears at the top of the list | pass | .artifacts/CRM-14/01-saved.png |
   ```

## Rules

- A failed assertion is a finding. Report it. Do not retry until it goes green, and do not weaken the assertion.
- Verify against the code you were asked to verify: state the commit in the report.
- Never reenact. If you forgot to record, say so; do not replay a passing run for the camera.
- No test data that looks real. No real credentials typed into a recorded session.
- **Orchestrator:** attach the recording to the Linear issue (the MCP can upload attachments) and link it in the PR. `gh` cannot attach a video to a PR comment.

## No desktop

On a server or in CI there is no Chrome to attach to. Add a headless Chrome service to `compose.yaml` that exposes CDP, and point browser-use at it with `BU_CDP_URL=http://localhost:<port>`. Everything above stays the same.

## The project's own map

`create-verification-skill` writes `verify-<app>`: how to boot this app, log in, seed data, and reach each feature. Tell it the driver is browser-use. When `verify-<app>` exists, follow it for the how and this skill for the discipline. `maintain-verification-skill` keeps it honest as the app changes.
