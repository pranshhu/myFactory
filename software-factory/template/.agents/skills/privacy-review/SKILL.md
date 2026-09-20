---
name: privacy-review
description: Orchestrator only. Use on any issue or PR that collects, stores, logs, exports or shares personal data - names, emails, phone numbers, addresses, IDs, payment details, IP addresses, location, or free text users type about people. Covers India's DPDP Act and GDPR.
---

# Privacy review

Not legal advice. It makes sure the questions a regulator, an auditor or a client's security questionnaire will ask already have answers in the repo. Label the issue `risk:privacy`; human review is mandatory.

## 1. Update the data map

`docs/privacy/data-map.md`, one row per personal data field the change adds or touches:

| Field | Whose | Purpose | Lawful basis / consent | Stored where | Retention | Shared with | Deletion path |
|---|---|---|---|---|---|---|---|

A row you cannot complete is a finding. "Purpose: might be useful later" is a finding: collect only what a stated purpose needs.

## 2. Check the diff

- **Logs, traces, error reports and analytics carry no personal data.** Log ids, not emails. Check the Sentry and OpenTelemetry scrubbing config when new fields appear.
- **Deletion works.** Deleting the person removes or anonymises this field everywhere it was copied: caches, search indexes, exports, files. Backups age out within the stated retention.
- **Export works.** The field shows up in the data export the person can request.
- **Retention is code, not intent.** A scheduled job or TTL enforces it.
- **Every new processor is recorded.** Any third party that receives the field (email, SMS, analytics, LLM APIs) is in the data map, under a data processing agreement, and the data's region is known. Personal data sent to an LLM provider is a disclosure like any other.
- **Consent is specific, recorded and as easy to withdraw as to give.** No pre-ticked boxes. Children's data needs verifiable parental consent under DPDP.
- **Sensitive reads are audited.** Staff, admin and support access to personal data writes an audit log entry.
- **Non-production environments use synthetic or masked data.**

## 3. Report

Comment on the PR with: fields touched, data map rows added, findings with `file:line`, and a verdict of `pass`, `pass with follow-ups` (each filed as a Linear issue) or `block`. A breach-shaped finding (personal data already exposed) goes to the human immediately: both laws put notification on a clock.
