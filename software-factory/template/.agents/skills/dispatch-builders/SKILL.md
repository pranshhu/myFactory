---
name: dispatch-builders
description: Orchestrator only. Use when Ready Linear issues should be built. Gives each issue its own git worktree and a fresh builder (an agy account in a herdr pane, or a Claude Code builder subagent), waits, then hands the result to review-loop. Also covers how worktrees are used and when a slice may be split between a backend and a frontend builder.
---

# Dispatch builders

The build loop. It is `subagent-driven-development` with two changes: the builder can be an agy account in a herdr pane, and the run stops for a human after every batch.

## Before you start

- Pick at most **3** issues from Ready with no open blockers. If the human has not reviewed the previous batch's diffs, dispatch nothing.
- Two issues run in parallel only if neither blocks the other **and** they do not edit the same files. Check the program design's file-tree diff. When in doubt, run them one after the other.
- Every builder is **fresh**: no memory of the plan, of you, or of the last slice. The ticket is the whole contract, which is why a bad ticket is your bug, not the builder's.

## Which builder

| Builder | Use when | How it starts |
|---|---|---|
| **agy in a herdr pane** | The default for volume. `test "${HERDR_ENV:-}" = 1` passes and `~/agy-profiles/` has accounts. Spends Gemini quota, not yours | herdr, below |
| **`builder` subagent** | No herdr or no agy on this machine, Gemini quota exhausted, or a small stack where spinning up panes costs more than the slice | The Agent tool with `subagent_type: builder` |
| **You** | S tasks, and the hardest slices: concurrency, subtle algorithms, anything where judgment is the work | `/implement_plan`, in a worktree like everyone else |

Same ticket, same report, same review, whichever builds. One account per agy builder: `builder-a` uses `~/agy-profiles/acc1`, `builder-b` uses `acc2`; two issues on one account run one after the other.

## Worktrees

- One worktree per issue at `.worktrees/<KEY>`, on a new branch `<KEY>`, cut from an up to date `main` (`using-git-worktrees`). The key in the branch name is what links the PR to Linear.
- **One writer per worktree.** Never two agents in one checkout, and never a builder in the main checkout: that one is yours, and it stays on `main`.
- Start from green: run `make check` in the new worktree before dispatch. A builder that inherits a red baseline cannot tell its failures from yours.
- Each worktree gets its own Docker stack automatically (`docker-dev`). `make down` in it before removing it.
- A worktree lives until its PR merges, then `finishing-a-development-branch` removes it. Rework happens in the same worktree, by a fresh builder.

## Backend and frontend on one slice

Slices stay vertical: one user-visible behavior, end to end. But when a slice has a clean API seam **and** the approved program design fixes the endpoint's exact shape, `to-tickets` may split it into two issues, `<slice> · backend` and `<slice> · frontend`, that carry the same signatures and run in parallel in separate worktrees. The frontend builds against the agreed shape, not against the other builder's code. Add a third issue, blocked by both, whose whole job is the end-to-end `browser-verification`. The slice is not done until that one passes.

Never split further into layers (all migrations, then all services, then all routes). Nothing is testable until the end and every mistake surfaces at once.

## Per issue

1. **Worktree**, as above.
2. **Ticket snapshot.** Fetch the issue description from Linear and write it unchanged to `.worktrees/<KEY>/thoughts/runs/<KEY>-ticket.md`. Linear stays the source of truth; this file is a delivery mechanism, rewritten on every dispatch and never edited. If the description does not match the ticket template in `CLAUDE.md`, fix the Linear issue first.
3. **Start the builder.**

   agy through herdr. Installing the factory is the human's explicit authorization to use herdr here. Syntax was checked against herdr 0.9, but **the installed binary is the authority**: run `herdr agent` and `herdr pane` for usage and read the `herdr` skill before the first dispatch of a session. The account's environment goes on the pane, not on the agent:

   ```bash
   pane=$(herdr pane split --current --direction right --cwd ".worktrees/<KEY>" \
     --env HOME="$HOME/agy-profiles/acc1" --no-focus | jq -r .result.pane.pane_id)
   herdr agent start builder-a --kind agy --pane "$pane"
   herdr agent prompt builder-a "Read AGENTS.md, then thoughts/runs/<KEY>-ticket.md. Execute the ticket exactly. Reply with only the path of your report." --wait --timeout 2700000
   ```

   The prompt is one line so that nothing depends on how a TUI handles a multi-line paste.

   `builder` subagent: call the Agent tool with `subagent_type: builder`, in the background, with the prompt `Your worktree is <absolute path to .worktrees/KEY>. Read AGENTS.md there, then thoughts/runs/<KEY>-ticket.md. Execute the ticket exactly.` Launch the whole batch in one message so they run concurrently.

4. **Linear.** Move the issue to In Progress. Comment the builder's name and the worktree path.

Start every builder of the batch before waiting on any of them.

## When a builder settles

- **herdr says `blocked`**: it is showing a permission or question dialog. `herdr agent read <name> --source recent-unwrapped --lines 120`, then answer if the action is inside the ticket and reversible. Otherwise ask the human. Never re-send the prompt: a timeout does not prove it was not delivered.
- **A builder asks a question or reports a deviation**: if the answer is in the plan, answer it. If the plan is wrong, record it as a comment on the Linear issue, fix the issue description, and re-dispatch. A blocker that needs the human becomes a Linear comment that mentions them, and the issue gets a `blocked by` relation if another issue is the cause.
- **Finished**: read `thoughts/runs/<KEY>-report.md` in the worktree. No report means not done; find out why.

Then run `review-loop` on each finished issue. Close the pane once its issue is in review.

Finish the batch by telling the human which PRs are waiting and what you were unsure about. Then stop. The next batch starts when they say so.

## After a reboot

herdr restores the layout, not the processes, and background subagents are gone. Treat any unfinished issue as never dispatched: `make down`, delete the worktree, start again from step 1. Tickets are self-contained so that this is always safe.
