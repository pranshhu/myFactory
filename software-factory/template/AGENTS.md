# AGENTS.md: rules for every agent in this repo

Two kinds of agent work here.

- **Orchestrator**: Claude Code, started by the human, connected to Linear. Read this file, then `CLAUDE.md`.
- **Builder**: any agent that was handed one ticket inside `.worktrees/<ISSUE-KEY>/`. This file is your whole operating manual.

## Always

1. **Ponytail is always on.** Whenever you write or change code, `.agents/rules/ponytail.md` applies at level `full`. Climb its ladder and stop at the first rung that holds: does it need to exist, is it already in this codebase, does the standard library do it, does the platform do it, does an installed dependency do it, can it be one line, and only then the least code that works. Nobody has to ask for it and nothing switches it off. It never trims validation at trust boundaries, error handling that prevents data loss, security, or accessibility. When you cut a real corner on purpose, leave a `ponytail:` comment that names the ceiling and the upgrade path; `ponytail-debt` collects them.
2. **Project code runs in Docker, never on the host.** Build, test, migrate and run through `make up`, `make check`, `make shell` (`docker-dev`). You run whatever the code you just wrote says, and a container is where that is allowed to go wrong.
3. **One browser tool: `browser-use`.** Anything visible in a browser is verified by driving the real app with it (`browser-verification`). Never add or run Playwright, Puppeteer, Cypress or Selenium.
4. **Shared vocabulary.** Use the terms in `CONTEXT.md` exactly. One term per concept, in code, tests and prose.
5. **Test first.** Write the failing test, watch it fail, then write the code (`test-driven-development`). Test behavior, not implementation: a test that still passes when the function returns nothing is not a test.
6. **Fix root causes.** Reproduce the bug before touching it (`systematic-debugging`). No null-check band-aids.
7. **Prove it works.** Verify against the real running thing, not "it compiles". Never say done without fresh command output in front of you (`verification-before-completion`).
8. **Look before you grep.** `graphify explain "<thing>"` and `graphify path "<A>" "<B>"` answer "what is this and what touches it" from `graphify-out/graph.json` faster than reading files. Edges tagged EXTRACTED were read from source; INFERRED ones are guesses to confirm.
9. **Stop when reality disagrees with the plan.** Report `Expected / Found / Why this matters` and wait. Do not improvise around a plan.
10. **Irreversible actions belong to the human.** Force-push, deploys, destructive migrations, deleting data, messaging customers.

## Builder contract

You start with no memory of the plan. The ticket you were handed is the whole contract.

- Read the files listed under the ticket's **Read first** before anything else.
- Build exactly what **Build** says. Nothing from later phases, no drive-by refactors.
- Signatures in the ticket were approved by a human. If one cannot work, stop and say so in the report. Do not change it.
- Stay inside your worktree and on the branch named after the issue key. Put the issue key in every commit message.
- Commit locally. Do not push, open PRs, merge, or touch `main`, other worktrees, `.agents/`, `.claude/`, `.github/`, secrets, or Linear. The orchestrator does all of that after review.
- **Finish** by writing `thoughts/runs/<ISSUE-KEY>-report.md`, committing it, and replying with only its path:

```markdown
# <ISSUE-KEY> report
## What changed        (files and why, in a few lines)
## Verification        (each "Done means" command and its pasted output; the browser-verification table for UI)
## Deviations          (Expected / Found / Why this matters, or "none")
## Open questions      (or "none")
```

### Skills builders use

Read the skill before the work it covers. Everything else in `.agents/skills/` belongs to the orchestrator.

| When you | Use |
|---|---|
| write any code | `ponytail` rules (always on), `test-driven-development` |
| run anything | `docker-dev` |
| hit a bug or a failing test | `systematic-debugging` |
| change the database schema or backfill data | `migration` |
| read or write tenant-owned data | `tenant-scoping` |
| change something visible in a browser | `browser-verification`, and `verify-<app>` if it exists |
| were handed review findings to fix | `receiving-code-review` |
| are about to say done | `verification-before-completion` |

## Where things live

| Path | Holds |
|---|---|
| `CONTEXT.md` | Domain vocabulary |
| `docs/adr/` | Decisions, one file each |
| `docs/agents/` | How agents work here: skills catalog, issue tracker, machine setup |
| `thoughts/research/` | Research station output |
| `thoughts/product/` | Product reviews and HTML mockups |
| `thoughts/plans/` | Plans and program designs |
| `thoughts/runs/` | Builder ticket snapshots and reports |
| `thoughts/handoffs/` | Session handoffs |
| `graphify-out/` | The code graph |
| `.agents/skills/` | Every skill (`.claude/skills` is a symlink to it) |
| `.worktrees/<ISSUE-KEY>/` | One checkout per issue, deleted after merge |
| `.artifacts/<ISSUE-KEY>/` | Recordings and screenshots. Gitignored; uploaded, never committed |
