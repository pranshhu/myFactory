---
name: review-loop
description: Orchestrator only. Use when a builder reports a slice finished, when you finish a slice yourself, and when a human leaves review comments on a PR. The ordered review every change passes before a human sees it, what happens on failure, and how it is recorded in Linear.
---

# Review loop

Builders are rewarded for green tests, not for good design. Review is where design gets defended. You are a different model family from the builders, which is the point of the cross-check, so read the diff; a report is a claim.

Every reviewer is a **fresh subagent that did not write the code** and sees only the ticket and the diff. A reviewer that shares the author's context shares the author's blind spots.

## The order

Stop at the first stage that fails. Later stages on a wrong diff are wasted.

| # | Stage | Skill | Question |
|---|---|---|---|
| 0 | Evidence | `verification-before-completion`, `browser-verification` | Rerun `make check` and every Done-means command yourself. Do they pass on this commit? |
| 1 | Spec | `requesting-code-review` | Does the diff do exactly the ticket? Nothing missing, nothing extra, signatures as approved? |
| 2 | Quality | `requesting-code-review` | Deep modules or pass-through layers? Do the tests fail when the behavior breaks? Any blanket try/catch, type cast or null check that hides a problem instead of fixing it? |
| 3 | Less | `ponytail-review` | What can be deleted? Reinvented stdlib, new dependencies, speculative options |
| 4 | Risk, when it applies | see below | |
| 5 | Polish | `no-comments`, `unslop` | Comments that narrate, AI tells in the commit and PR text |

Stage 4 is conditional:

| When the diff | Run |
|---|---|
| touches code other slices or modules call | `blast-radius`: prove, by running code, the one fact that makes it safe |
| carries a `risk:` label | `risky-changes`, and a human review is mandatory |
| changes schema or backfills | check it against `migration` |
| reads or writes tenant data | check it against `tenant-scoping`; the two-tenant test must exist |
| touches personal data | `privacy-review` |
| touches auth, input handling, file or network access | `security-loop`, the pre-PR part |

## Verdict

**Pass.** Push the branch. Open the PR with `technical-writing`: what and why, how it was verified, the evidence link, the issue key. GitHub moves the issue to In Review. Comment on the Linear issue: stages run, anything you were unsure about.

**Fail.** File a Linear sub-issue whose description is a ticket in its own right: each finding with `file:line`, why it matters, and what done looks like. Move the parent back to In Progress and dispatch the sub-issue to a **fresh** builder (`dispatch-builders`). Do not repair the work yourself: if you fix it quietly, the ticket, the skill or the design that caused it never gets fixed.

**Second fail on the same issue.** Stop. Add the `bounced` label and bring both reports to the human. Two failures mean the ticket or the design is wrong, not the builder. This label is what the end-of-cycle learning review reads.

## When the human comments on the PR

Use `receiving-code-review`. Check each comment against the code before acting on it. If it is right, it becomes a sub-issue like any other finding. If it is wrong, answer with evidence; agreeing to be agreeable is a failure. Unclear comments get a question, not a guess.

## Record

Every round leaves a Linear comment: round number, verdict, stages run, link to the findings sub-issue or the PR. Reviews that happened only in a terminal did not happen.
