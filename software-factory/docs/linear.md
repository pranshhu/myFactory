# Linear setup (once per team)

**Linear is the state. The repo is the evidence.** Every station of the pipeline is a workflow state, and every artifact is linked from the issue. Only Claude Code moves issues; builders never see Linear. The rules the orchestrator follows are in the project's `CLAUDE.md`; this page is the clicking you do once.

## Workflow states

Settings → Team → Workflow. The type decides how Linear counts the issue, so only `Done` is Completed: merged is not done.

| State | Linear type | Means |
|---|---|---|
| Triage | Triage | Unsorted: requests, bugs, incidents |
| Backlog | Backlog | Sized and labeled by the router |
| Research | Started | Research station running or awaiting your approval |
| Design | Started | Plan and program design |
| Ready | Unstarted | Approved slice, no open blockers. This column is the builders' queue |
| In Progress | Started | With a builder |
| In Review | Started | PR open. This column is your daily review queue |
| Merged | Started | On main, dark behind a flag |
| Released | Started | Canary signed off, 24 h watch running |
| Done | Completed | 24 h with no linked incident |
| Canceled / Duplicate | Canceled | |

## Labels

Three label groups, so an issue carries at most one of each `type` and `size`:

- **type**: `feature` `bug` `incident` `chore` `debt` `decision`
- **size**: `S` `M` `L`, set by the router at triage
- **risk**: `billing` `auth` `data` `infra` `privacy`. Any of these forces `risky-changes` and a mandatory human review

One loose label, `bounced`: `review-loop` adds it when an issue fails review twice. The end-of-cycle learning review is a filter on this label.

Plus `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling`, `wayfinder:task` if you use `wayfinder` for multi-session efforts. Claude Code can create labels through the MCP; workflow states it cannot.

## GitHub integration

Settings → Integrations → GitHub, then per team under Workflow → Git automations:

- PR opened → **In Review**
- PR merged → **Merged**

Linking works off the issue key in the branch name (`CRM-14`), which `dispatch-builders` guarantees. That removes two manual moves per slice.

## What lives where

| Linear object | Factory meaning | Created by |
|---|---|---|
| Team | One per product | you, once |
| Initiative | A client engagement or a quarter's goal | you |
| Project | One L feature. Its documents link the research, plan and program design | Claude Code at Research |
| Issue | One vertical slice sized for a single builder session. The description is the ticket | `to-tickets` |
| Sub-issue | Rework from a failed review, or a follow-up found while building | Claude Code |
| Blocked-by relation | The dependency graph. Ready means no open blockers | `to-tickets` |
| Cycle | Two weeks. The batch of Ready issues you release | you |
| Link attachment | Evidence: the run report, the recording, the PR | Claude Code |

Linear has no custom fields, so evidence is attached as links on the issue.

One caution: the issue description is the **single copy** of a ticket. When a builder finds the plan wrong, Claude Code edits the issue, never a file in the repo. Two copies of a ticket drift within a week. (The `thoughts/runs/<KEY>-ticket.md` a builder reads is a snapshot rewritten at every dispatch, not a copy anyone edits.)

## Client visibility

Share a view filtered to one initiative and to the states Released and Done. Clients see what shipped, never the internal states. It replaces the status email.
