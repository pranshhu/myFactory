---
name: tenant-scoping
description: Use whenever a change reads or writes tenant-owned data in a multi-tenant app - a new query, endpoint, background job, webhook, cache key, export or admin tool. Makes cross-tenant access impossible by construction instead of by remembering a WHERE clause.
---

# Tenant scoping

One tenant seeing another tenant's data ends a SaaS. A `WHERE tenant_id = ?` that each developer must remember will eventually be forgotten, so isolation is enforced below the application code, and proven by a test.

## Rules

1. **The database enforces it.** On Postgres, row-level security on every tenant table, keyed on a per-transaction setting (`SET LOCAL app.tenant_id`). The application's database role is neither superuser nor table owner, and has no `BYPASSRLS`. On a database without RLS, rule 2 carries the full weight.
2. **One choke point.** All data access goes through one module that takes the tenant from the authenticated context and applies it. Nothing else imports the raw database client; a lint rule fails the build when something does.
3. **The tenant comes from the session, never from the request.** A `tenant_id` in a body, query string or path is an input to authorize against, never a value to trust.
4. **No ambient tenant outside a request.** Jobs, webhooks, scheduled tasks and scripts receive the tenant id explicitly and set it before their first query. Work that spans tenants (billing runs, admin tools) uses a separate, named, audited path.
5. **Everything keyed by tenant.** Cache keys, file and blob paths, search indexes, rate limits, idempotency keys.
6. **Uniqueness is per tenant.** `UNIQUE (tenant_id, email)`, not `UNIQUE (email)`, unless global uniqueness is the actual requirement.

## The test every slice adds

A fixture with two tenants, A and B, each with data. For each new query or endpoint, as tenant B:

- reading A's record by id returns not-found, not forbidden (do not confirm it exists);
- list and search results contain nothing of A's;
- updating or deleting A's record changes nothing, asserted by reading it back as A.

If the test cannot be written because the code has no seam for a second tenant, that is the finding. Report it instead of working around it.
