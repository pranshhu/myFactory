# Issue tracker: Linear

Issues, specs and decisions for this repo live in Linear. Use the Linear MCP tools for every operation; there is no CLI. Only the orchestrator has Linear access. Builders never do.

**Team:** <!-- Linear team key, e.g. CRM -->

## Conventions

- **Create an issue**: in the team above, state `Triage` unless a skill says otherwise. Slices produced by `to-tickets` use the ticket template in `CLAUDE.md` as the description, verbatim.
- **Read an issue**: fetch it with its comments, labels, relations and sub-issues.
- **Labels**: three groups. `type:` feature, bug, incident, chore, debt, decision. `size:` S, M, L. `risk:` billing, auth, data, infra, privacy. Create a missing label rather than inventing a synonym.
- **Blocking**: Linear's native `blocked by` relation. An issue is ready when it has no open blockers.
- **States**: move issues only as the transition table in `CLAUDE.md` allows. Never set `Done` by hand.
- **Branches and commits** carry the issue key (`CRM-14`), which is how Linear's GitHub integration links PRs and moves issues to In Review and Merged.
- **Artifacts**: link research docs, plans, program designs, run reports and recordings from the issue or its project. The description is the single copy of a ticket; when a plan turns out wrong, edit the issue, not a file.

## When a skill says "publish to the issue tracker"

Create a Linear issue in the team above.

## When a skill says "fetch the relevant ticket"

Fetch the Linear issue by key, with comments.

## Wayfinding operations

Used by `wayfinder`. The **map** is a Linear project document; tickets are issues in that project.

- **Map**: a document named `Wayfinder map` in the Linear project, holding Notes / Decisions so far / Not yet specified.
- **Child ticket**: an issue in the same project, labels `type:decision` and `wayfinder:<type>` (`research`, `prototype`, `grilling`, `task`).
- **Blocking**: the native `blocked by` relation.
- **Frontier query**: the project's open issues with no open blockers and no assignee; first in map order wins.
- **Claim**: assign the issue to yourself, as the session's first write.
- **Resolve**: comment the answer, close the issue, record the decision with `adr-verbatim`, and append a pointer to the map's Decisions so far.
