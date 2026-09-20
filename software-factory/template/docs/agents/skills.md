# Skills catalog

Every skill, command, subagent and tool in this project: what it does, who runs it, and when. Skills live in `.agents/skills/` (Claude Code sees them through the `.claude/skills` symlink), commands in `.claude/commands/`, subagents in `.claude/agents/`. Where each came from, and at which commit, is in `.agents/skills.sources.tsv`.

**Runs:** `O` orchestrator (Claude Code) · `B` builders · `all` everyone, always on.

## Rules for using skills

1. **One skill per job.** The set is curated so that no two skills answer the same question. Do not install a second TDD, review or handoff skill; two skills for one job make agents arbitrate instead of work.
2. **Read the skill before the work it covers**, every time. Skills change; memory of a skill is not the skill.
3. **The station decides the skill** (`CLAUDE.md`), not the mood. A skill is not skipped because the task felt small: the router decided the path once, up front.
4. **Builders use the short list in `AGENTS.md`.** Everything else is the orchestrator's.
5. **Human gates inside a skill are real.** When a skill says stop and wait for approval, stop.
6. **A skill that was wrong gets edited**, with `writing-for-agents`, through a PR like any other change. Do not work around it twice.
7. **Adding or updating a third-party skill:** read its diff first. A skill runs with your permissions.

## Always on

| Skill | Runs | What it does |
|---|---|---|
| `.agents/rules/ponytail.md` | all | The least-code ladder, level `full`. Loaded into every agy session natively and into Claude Code through the import at the top of `CLAUDE.md`. Applies to every line of code written here, without being asked |
| `ponytail` | all | The same rules as an invocable skill, with levels: `lite` (build what was asked, name the lazier option), `full` (default: the ladder enforced), `ultra` (deletion before addition, challenge the requirement). The factory runs `full`; a human may ask for `ultra` on a cleanup or `lite` on a spike |
| `principle-prove-it-works` | all | Before declaring done, verify against the real artifact: run the feature, read the actual value. Not a proxy, not "it compiles" |
| `principle-fix-root-causes` | all | Reproduce first, ask why until you reach the cause, fix it there. No guards that silence a crash |
| `principle-test-behavior-not-implementation` | all | Call code the way its users do and assert what they observe. If the test passes when every function returns nothing, rewrite it |
| `docker-dev` | all | Project code runs only in containers, through `make` targets. One stack per worktree, no fixed ports, no real credentials |
| command guard | O | `.agents/hooks/deny-dangerous.sh`, a Claude Code PreToolUse hook. Blocks `rm -rf /`, force-push, deleting `main`, `terraform destroy`, reading login tokens and private keys |

The rest of ponytail, used at fixed points:

| Skill | Runs | When |
|---|---|---|
| `ponytail-review` | O | Every review (`review-loop` stage 3). One line per finding: where, what to cut, what replaces it |
| `ponytail-audit` | O | End of each cycle, whole repo: a ranked list of what to delete or replace with stdlib. Findings become `type:debt` issues |
| `ponytail-debt` | O | End of each cycle: harvests every `ponytail:` comment into a ledger so deliberate shortcuts are tracked, not forgotten. Each entry becomes or updates a `type:debt` issue |
| `ponytail-help` | O | Quick reference card for ponytail's modes and commands |

## Station 1 · Intake

| Skill | Runs | What it does |
|---|---|---|
| `setup-matt-pocock-skills` | O | Once per repo. Records the issue tracker, triage labels and domain-doc layout in `docs/agents/`. The Linear tracker doc ships with the factory; keep it |
| `triage` | O | Moves incoming issues through triage roles: categorise, verify, grill if unclear, write an agent-ready brief. The router (S/M/L, `type:`, `risk:`) runs here |
| `before-building` | O | The moment a build is proposed, surfaces the one to three consequential choices hidden in the idea. Twelve lines; good on a client call |
| `grill-with-docs` | O | A relentless interview that sharpens the requirement and writes the glossary and ADRs as it goes. The default for anything with code |
| `grill-me` | O | The same interview without the docs, for ideas that have no codebase yet |
| `grilling` | O | The interview engine the two above call. Not invoked directly |
| `domain-modeling` | O | Builds and maintains `CONTEXT.md`: one precise term per concept, so agents stop spending twenty vague words where one exact one exists |

## Station 2 · Research

| Skill | Runs | What it does |
|---|---|---|
| `/research_codebase` | O | Fans out reader subagents over **this codebase**: where things live, how they work, what to copy. Writes `thoughts/research/`. A wrong line here costs thousands of lines later, which is why a human approves it |
| `codebase-locator` · `codebase-analyzer` · `codebase-pattern-finder` | O (subagents) | Where it lives · how it works · existing examples to model on. Read-only, return `file:line` |
| `thoughts-locator` · `thoughts-analyzer` | O (subagents) | The same, over `thoughts/`: earlier research, plans and handoffs |
| `research` | O | Questions about the **outside world**: docs, third-party APIs, primary sources. Findings land as a Markdown file in the repo |
| `how` | O | "How does X work", walkthroughs before changing something, "where should this live" |
| `why` | O | "Why is it this way": digs through git history, Linear, docs and whatever MCPs are connected for the rationale |
| `prototype` | O | A throwaway artifact to answer one design question. Deleted afterwards; never promoted to production |

## Station 3 · Design and planning

| Skill | Runs | What it does |
|---|---|---|
| `/create_plan` | O | Interactive plan: current state, desired end state, "what we're NOT doing", phases with automated and manual success criteria |
| `/iterate_plan` | O | Revises a plan from human feedback |
| `codebase-design` | O | Vocabulary for deep modules: small interface, lots behind it. Where a seam goes |
| `code-structure` | O | Actions versus shared services, for SaaS backends where workflows repeat operational logic |
| `program-design` | O | **Factory skill.** File-tree diff, call-stack diff and exact signatures, approved by a human before any ticket is written. The highest-leverage review in the pipeline |
| `adr-verbatim` | O | Records a decision as an ADR in the human's exact words |
| `wayfinder` | O | For efforts too big for one session: a map of decision tickets on Linear, resolved one at a time |
| `to-spec` | O | Turns the conversation so far into a spec on the tracker. No interview, only synthesis |
| `to-tickets` | O | Breaks a plan into vertical, tracer-bullet tickets with native blocking relations, each sized for one fresh builder. The output must match the ticket template in `CLAUDE.md` |

## Station 4 · Build

| Skill | Runs | What it does |
|---|---|---|
| `dispatch-builders` | O | **Factory skill.** The build loop: worktree per issue, fresh builder per slice, at most three issues per batch, then stop for the human. Covers agy-in-herdr and the `builder` subagent, and the backend/frontend split |
| `builder` | O (subagent) | **Factory subagent.** Builds one ticket in one worktree when no agy builder is available or the stack is small |
| `herdr` | O | The CLI for herdr panes: split, start an agent, prompt, wait, read. Used through `dispatch-builders` |
| `using-git-worktrees` | O | Creates the isolated checkout and verifies a clean baseline |
| `subagent-driven-development` | O | The upstream pattern `dispatch-builders` specialises: fresh subagent per task, spec review then quality review. Read it for the reasoning; follow `dispatch-builders` for the procedure |
| `/implement_plan` | O | For slices the orchestrator keeps: phase by phase, ticking the plan's checkboxes, stopping with Expected / Found / Why when reality differs |
| `test-driven-development` | B, O | Red, green, refactor. Code written before its test gets deleted |
| `systematic-debugging` | B, O | Four phases to a root cause before any fix is proposed |
| `migration` | B | **Factory skill.** Expand, migrate, contract across three releases. Reversible, lock-aware, rollback proven |
| `tenant-scoping` | B | **Factory skill.** Isolation enforced by the database and one choke point, proven by a two-tenant test |

## Station 5 · Verify

| Skill | Runs | What it does |
|---|---|---|
| `verification-before-completion` | B, O | No claim of done, fixed or passing without the command's fresh output |
| `browser-verification` | B, O | **Factory skill.** Drives the running app with browser-use, records it, reports an assertion table. Replaces Playwright-style e2e |
| `browser-use` | B, O | The browser tool's API: CDP control through the accessibility tree, screenshots, recordings |
| `create-verification-skill` | O | Once the app boots: generates `verify-<app>`, the project's own map of how to start, log in, seed and reach each feature |
| `maintain-verification-skill` | O | Periodic pass that keeps `verify-<app>` true as the app changes |
| `/validate_plan` | O | Confirms the implementation matches the plan, phase by phase |

## Station 6 · Security and privacy

| Skill | Runs | What it does |
|---|---|---|
| `security-loop` | O | **Factory skill.** The three rings: automatic gates on every PR, a white-box pass before risky PRs, a pentest before major releases. How findings and leaked secrets are handled |
| `find-security-vulnerabilities-in-code` | O | Strix white-box review: reads the data flow and authorization model, then proves what it finds in a sandbox |
| `fix-security-vulnerabilities-with-strix` | O | Triage by severity, patch the root cause, rerun to prove the exploit is closed |
| `web-app-penetration-testing` | O | Black-box pentest of a running web app: local Docker stack or staging |
| `api-security-testing` | O | REST, GraphQL, gRPC: enumerates from the schema and attacks the OWASP API classes |
| `owasp-top-10-testing` | O | A pass over each OWASP Top 10 category with real exploit attempts |
| `penetration-testing-with-strix` | O | The general entry point: any target type, one command |
| `application-security-testing` | O | Decides which asset needs which test, and ranks the remediation plan |
| `ci-security-scanning-with-strix` | O | For changing the CI gate itself |
| `managed-pentesting-with-strix` | O | The same tests on Strix's cloud. Uploads source, so the human decides per project |
| `privacy-review` | O | **Factory skill.** Data map, retention, deletion, export, processors, consent. DPDP and GDPR |

Strix needs Docker and an LLM key, and only ever targets your own code and environments.

## Station 7 · Review

| Skill | Runs | What it does |
|---|---|---|
| `review-loop` | O | **Factory skill.** The order (evidence, spec, quality, less, risk, polish), pass and fail, the two-strike rule, recording in Linear |
| `requesting-code-review` | O | Dispatches a fresh reviewer subagent with a precise brief |
| `receiving-code-review` | B, O | Evaluate feedback technically before acting. No performative agreement, no blind implementation |
| `blast-radius` | O | What could this change break elsewhere? Proves the one fact that makes it safe by running code |
| `risky-changes` | O | Forced by `risk:` labels. Verifies assumptions against the real world before billing, pricing, quota or API changes |
| `no-comments` + `Comment Sicko` | O | A subagent that hunts narration, banners and commented-out code; accepted findings get fixed |
| `unslop` | O | Cuts AI tells from commit messages, PR text, docs and client-facing writing |

## Station 8 · Ship and operate

| Skill | Runs | What it does |
|---|---|---|
| `finishing-a-development-branch` | O | Merge, PR, keep or discard; then worktree cleanup |
| `resolving-merge-conflicts` | O | Parallel builders guarantee conflicts. Resolves them by understanding both sides |
| `infra-change` | O | **Factory skill.** Infrastructure only as code; agents plan, humans apply; the plan output is in the PR |
| `technical-writing` | O | The standard for docs, runbooks, PR descriptions and changelogs |
| `teach` | O | Runs `how` and `why` and weaves them into one explanation. For onboarding a teammate or explaining a change to a client |

## Continuity and learning

| Skill | Runs | What it does |
|---|---|---|
| `/create_handoff` · `/resume_handoff` | O | Compaction: at about 60% context, write the state to `thoughts/handoffs/` and start fresh. The same file hands work to a teammate |
| `reflect` | O | After an L task: three reviewers over the transcript, each learning routed to a concrete skill edit |
| `writing-for-agents` | O | How to write skills, `AGENTS.md` and `CLAUDE.md` so agents follow them |

## Tools

| Tool | Role | How it is used here |
|---|---|---|
| **Linear** (MCP, `.mcp.json`) | The state | Every issue, to-do, blocker, review and decision. Only the orchestrator touches it. `docs/agents/issue-tracker.md` |
| **herdr** | Runtime | One session per project: Claude Code in the first pane, agy builders in the others. Survives detach |
| **agy** (Antigravity CLI) | Builders | One `HOME` profile per Gemini subscription, so each builder spends its own quota |
| **Docker** | Containment and sameness | All project code. `docker-dev` |
| **browser-use** | The only browser tool | `browser-verification`. No Playwright, Puppeteer, Cypress or Selenium |
| **graphify** | The map of the code | `graphify-out/graph.json`, built locally with tree-sitter (no LLM for code). `graphify explain`, `graphify path`; `graphify update .` after each merged batch |
| **MemPalace** (MCP, `.mcp.json`) | Agent memory | Verbatim, local, semantic search. Orchestrator searches before research and design, files decisions after gates. A team can share one palace with `mempalace serve` |
| **Mem0** | Product memory | Not installed. Add it only when the product itself must remember its users, and then point agents at that same server instead of MemPalace. Never both |
| **Strix** | Security testing | CI gate on every PR, pentest before releases |
| **gitleaks · semgrep · Renovate** | CI gates | Secrets, static analysis, dependencies |

## Deliberately not installed

| Left out | Why |
|---|---|
| superpowers `using-superpowers`, `brainstorming` | They force themselves on every message and fight `grill-with-docs`. Do not enable the superpowers plugin in factory projects |
| superpowers `writing-plans`, `executing-plans` | `/create_plan` + `to-tickets` and `dispatch-builders` own those jobs |
| pstack `poteto-mode`, `arena`, `swarm`, `interrogate`, `architect` | Need Cursor's per-call model routing. Two builders on one ticket approximates `arena` when it matters |
| Matt's `tdd`, `teach`, `handoff`; pstack's `tdd`, `unslop`; David's `handoff` | Duplicates of a chosen skill |
| Michael's `evidence-driven-testing`, `before-and-after` | Record the desktop and fall back to Playwright. `browser-verification` does the job with browser-use |
| Michael's `greploop` | Needs a paid Greptile account |
| `ponytail-gain` | A benchmark scoreboard, not a working skill |
| David's DeepAPI, `bb`, `cmux`, macOS ops skills | Tied to paid services or personal tooling |
| Orca | herdr does the same job in the terminal and is scriptable |
