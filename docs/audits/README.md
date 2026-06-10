# Audits & Reports — IntegratedAccountsSystem

> All audit, security, migration, and review reports for the project, organized by date and category.

---

## Current Audits (PostgreSQL era, 2026-06-08)

| File | Date | Scope | Status |
|---|---|---|---|
| `ARCH_AUDIT.md` | 2026-06-08 | Full architecture audit — 15 findings + remediation | Latest, actionable |
| `PL_Migration_Report.md` | 2026-06-08 | PL layer analysis — **0 changes needed** | Confirmed 3-tier works |
| `BL_Audit_Report.md` | 2026-06-08 | BL pre-migration state (606 SqlParameter→NpgsqlParameter) | Historical snapshot |
| `SECURITY_AUDIT_REPORT.md` | 2026-06-08 | Security review (PBKDF2, SQL injection, DPAPI) | Findings fixed per CHANGELOG |
| `FINAL_REPORT.md` | 2026-06-08 | **Consolidated v1+v2+v3** migration report | Authoritative current state |

---

## Historical Audits (kept for reference)

These audits document the project state **before** the PostgreSQL migration (SQL Server 2019 era, 2025).

| File | Date | Original Location | Why archived |
|---|---|---|---|
| `historical/CMP_Comprehensive_Project_Map_2025-03.md` | 2025-03 | `docs/CMP_Comprehensive_Project_Map.md` | SQL Server era project map; large (50 KB) |
| `historical/presentation_content_script_2025-03.md` | 2025-03 | `docs/architecture_content_script.md` | SQL Server era slides script |
| `historical/DatabaseArchitectureReport_2025-01-19.md` | 2025-01-19 | `docs/DatabaseArchitectureReport.md` | SQL Server schema proposal (pre-PostgreSQL) |

> These are kept in `historical/` for traceability, but **the current authoritative architecture is in [`../architecture/`](../architecture/README.md)**.

---

## Final Report — Reading Guide

The consolidated `FINAL_REPORT.md` is split into three sections (one per migration phase):

- **Section A — v1.0 Core Migration** — initial SQL Server → PostgreSQL port (37 tables, 13 BL files)
- **Section B — v2.0 Routine Coverage** — +88 stored procedures, audit log schema extension, seed data
- **Section C — v3.0 Verification & Polish** — 118/118 BL/PL coverage check, 0 build warnings, full smoke test

The top of the file has a "Current State" header with the verified final counts.

---

## Other (Removed)

These were duplicates or one-off artifacts and have been **removed** (in trash, recoverable):

- ~~`Reports/Architecture_Audit_Report.md`~~ — superseded by `ARCH_AUDIT.md`
- ~~`Reports/Deep_Audit_Report.md`~~ — same content, older
- ~~`Reports/Microsoft_WinForms_3Tier_Audit.md`~~ — same content, different angle
- ~~`docs/FINAL_REPORT_v2.md`~~, ~~`docs/FINAL_REPORT_v3.md`~~ — merged into consolidated `FINAL_REPORT.md`
- ~~`docs/DELIVERY_SUMMARY.md`~~ — superseded by CHANGELOG + FINAL_REPORT
- ~~`docs/DOCS_CLEANUP_REPORT.md`~~ — this report's predecessor, archived externally

---

## See Also

- [Architecture docs](../architecture/README.md) — PL/BL/DAL system architecture
- [Project README](../README.md) — Project entry point
- [Changelog](../CHANGELOG.md) — Version history
