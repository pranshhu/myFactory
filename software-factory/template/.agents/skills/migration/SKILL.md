---
name: migration
description: Use whenever a change adds, alters, renames or drops a table, column, index or constraint, or backfills data. Keeps schema changes backward compatible and reversible so a deploy can always be rolled back.
---

# Migration

The old code and the new code run side by side during every deploy and after every rollback. A migration is safe only if **both** versions work against the schema it leaves behind.

## Expand, then contract, never in one release

| Release | Schema | Code |
|---|---|---|
| 1 expand | Add the new column or table. Nullable or defaulted. Nothing removed. | Writes both old and new. Reads old. |
| 2 migrate | Backfill. | Reads new. Still writes both. |
| 3 contract | Drop the old column or table. | No reference to the old one anywhere. |

A rename is an add plus a drop, so it takes all three. A slice contains one row of this table. The drop ships in a later release than the code that stopped using the column, and it carries the `risk:data` label.

## Rules

- Every migration has a working down step, tested. When a down step is impossible (dropped data), write `IRREVERSIBLE` and the reason at the top of the file and in your report. The human approves those individually.
- Never edit a migration that has been merged. Write a new one.
- Do not lock a hot table. On Postgres: `CREATE INDEX CONCURRENTLY`; add `NOT NULL` through a `CHECK ... NOT VALID` constraint validated afterwards; no column default that forces a table rewrite.
- Backfills run in batches, outside the schema transaction, and are idempotent: killing and re-running one must be safe.
- New tables that hold tenant data get their tenant column and policy in the same migration (`tenant-scoping`).

## Done means

Paste the output of each into your report:

1. Migrate up on a database shaped like production (restored dump or seeded to realistic row counts), with timing.
2. The **previous** release's test suite against the new schema. This is the rollback proof.
3. Migrate down, then up again.
