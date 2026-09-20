---
name: program-design
description: Orchestrator only. Use after a plan is approved and before any ticket is written or code is built, for every L task and any M task that adds a module boundary. Produces the file-tree diff, call-stack diff and exact signatures a human approves.
---

# Program design

A wrong line of code is one wrong line. A wrong line in a design is hundreds. This document is where the human catches a bad design in ten minutes of reading instead of in two thousand lines of diff. It is the highest-leverage review in the pipeline, so make it short enough to actually be read: under 200 lines.

## Inputs

The approved plan in `thoughts/plans/`, the research doc it cites, `CONTEXT.md`. If the research does not show where the touched code lives and which existing helpers apply, go back to the research station. Do not design on guesses.

## Write `thoughts/plans/<KEY>-program-design.md`

1. **File tree diff.** Only files that change. `+` new, `~` modified, `-` deleted, each with a few words of purpose. Every `+` must say why an existing file could not hold it.

   ```
   src/contacts/
   ~ routes.ts          register GET /contacts/search
   + search.ts          query parsing and ranking, the only new module
   ~ repository.ts      add findByQuery
   ```

2. **Call-stack diff.** One tree per entry point (route, job, webhook, CLI command), from the outside in, marking what is new or changed. This is what shows whether the design is a deep module or a pile of pass-through layers.

   ```
   GET /contacts/search
   └─ ~ routes.searchHandler
      └─ + search.searchContacts(q, cursor)
         ├─   auth.currentTenant()            (existing)
         └─ + repository.findByQuery(tenantId, parsed, cursor)
   ```

3. **Signatures.** Exact, in the project's language: new and changed exported functions, key types, table and column changes, endpoint shapes. No bodies. Name things with `CONTEXT.md` terms.
4. **Reused, not rebuilt.** The existing helpers, types and patterns this design leans on, with `file:line`. If this section is empty, you did not look.
5. **Not doing.** What a reader might expect here that is deliberately out of scope.
6. **Slice map.** Which signatures land in which vertical slice. Every slice must be demonstrable end to end on its own: never "all migrations, then all services, then all routes".
7. **Open questions.** Anything you would otherwise guess.

## Rules

- Every signature appears in a call-stack tree and has a caller. Anything with no caller gets deleted from the design.
- Interfaces small, implementations deep (`codebase-design`). A new layer that only forwards its arguments is a defect.
- `ponytail` applies to designs too: fewest new files, fewest new concepts.
- Flag anything touching billing, auth, tenant data, infrastructure or personal data, so the issues get their `risk:` label.

## Gate

Link the document from the Linear project and stop. The human approves it in a comment or sends it back; use `/iterate_plan` on feedback. After approval the signatures are fixed: `to-tickets` copies them verbatim into each issue, and builders may not change them.
