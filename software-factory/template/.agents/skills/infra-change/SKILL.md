---
name: infra-change
description: Use for any change to infrastructure - cloud resources, DNS, networking, IAM, databases, queues, buckets, secrets, CI runners, environment variables of a deployed service. Infrastructure changes only through code, with the plan output reviewed by a human before anyone applies it.
---

# Infra change

If it was clicked in a console, it does not exist: nobody can review it, reproduce it or roll it back. Every infrastructure change is a PR. Label the issue `risk:infra`.

## Rules

1. **Code only.** Terraform/OpenTofu, or the platform's config file for a managed platform. If you find drift (the real thing differs from the code), report it and import it; do not overwrite it.
2. **Agents plan. Humans apply.** Run `plan` and never `apply` or `destroy`; the command guard blocks `destroy` and `-auto-approve`. Production applies run from CI after the PR merges, or by the human.
3. **The plan is in the PR.** Paste the full `plan` output in the description, with the summary line (`N to add, N to change, N to destroy`) on top.
4. **Destroy or replace on anything stateful stops the line.** Databases, volumes, buckets, queues, DNS zones, KMS keys. Say so in the first line of the PR and wait for the human. Check `forces replacement` in the plan: an innocent-looking attribute change can recreate a database.
5. **Secrets never enter code, variables files or state in plain text.** Reference a secret manager. Adding a secret is a human step; the PR says which name is needed and where.
6. **Least privilege.** New IAM grants name specific actions and resources. A wildcard needs a written reason.
7. **Every environment from the same code.** Staging and production differ by variables, not by copy-pasted modules.

## The PR description

```markdown
## What and why
## Plan            N to add, N to change, N to destroy   (full output below)
## Stateful resources touched     none | list, with destroy/replace called out
## Rollback        the exact steps, and what cannot be rolled back
## Cost            rough monthly delta
## Verified in staging            what you checked after the staging apply
```
