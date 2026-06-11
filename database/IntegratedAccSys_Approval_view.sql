-- =====================================================================
-- IntegratedAccSys — Approval Workflow Dashboard (Gap #10) — Part C
-- =====================================================================
-- Date        : 2026-06-11
-- Branch      : feat/gap-10-approval-workflow
-- Author      : GitHub Copilot (MiniMax-M3)
-- Plan        : docs/audits/GAP_10_APPROVAL_WORKFLOW_PLAN.md
--
-- Adds vw_approval_workflow_dashboard: a single view that joins
-- the request with the workflow, the latest action, and the
-- approver info.  Intended for the dashboard's
-- "pending approvals" and "in-flight requests" pages.
--
-- Conventions
--   - CREATE OR REPLACE VIEW  (idempotent)
--   - LATERAL JOIN to fetch the latest action per request
--   - No BEGIN/COMMIT (CREATE VIEW is auto-committed in psql)
-- =====================================================================

CREATE OR REPLACE VIEW public.vw_approval_workflow_dashboard AS
SELECT
    r.requestid,
    r.requestno,
    w.workflowcode,
    w.workflownamear,
    w.workflownameen,
    w.sourcetype,
    r.sourceid,
    r.requesterid,
    r.totalsum,
    r.currencycode,
    r.exchangerate,
    r.description,
    r.status,
    r.currentlevel,
    r.totallevels,
    r.priority,
    r.duedate,
    r.completedate,
    r.completedby,
    r.adddate,
    -- latest action (LATERAL join for performance)
    la.actiontype        AS last_action_type,
    la.actiondate        AS last_action_date,
    la.approverid        AS last_approver_id,
    la.oldstatus         AS last_old_status,
    la.newstatus         AS last_new_status,
    la.fromlevel         AS last_from_level,
    la.tolevel           AS last_to_level,
    la.comments          AS last_comments,
    -- derived flags (no extra DB lookups needed)
    (r.status IN ('PENDING', 'IN_REVIEW'))::boolean              AS is_open,
    (r.status = 'IN_REVIEW' AND r.duedate IS NOT NULL
        AND r.duedate < now())::boolean                         AS is_overdue,
    (r.status IN ('APPROVED','REJECTED','CANCELLED','EXPIRED'))::boolean AS is_terminal
FROM public.tblapprovalrequests r
JOIN public.tblapprovalworkflows w
      ON w.workflowid = r.workflowid
LEFT JOIN LATERAL (
    SELECT a.actiontype, a.actiondate, a.approverid,
           a.oldstatus,  a.newstatus,  a.fromlevel, a.tolevel, a.comments
      FROM public.tblapprovalactions a
     WHERE a.requestid = r.requestid
     ORDER BY a.actiondate DESC
     LIMIT 1
) la ON true;

GRANT SELECT ON public.vw_approval_workflow_dashboard
    TO app_admin, app_readwrite, app_auditor, app_reports;

-- Idempotency signature (Part C)
CREATE OR REPLACE FUNCTION public.fn_g10_approval_signature_part_c()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP10-APPROVAL-PART-C-2026-06-11-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g10_approval_signature_part_c() TO PUBLIC;

-- =====================================================================
-- End of IntegratedAccSys_Approval_view.sql (Part C)
-- Next commit will add the audit script.
-- =====================================================================
