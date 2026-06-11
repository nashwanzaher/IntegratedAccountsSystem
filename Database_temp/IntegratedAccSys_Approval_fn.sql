-- =====================================================================
-- IntegratedAccSys — Approval Workflow Helpers (Gap #10) — Part A
-- =====================================================================
-- Date        : 2026-06-11
-- Branch      : feat/gap-10-approval-workflow
-- Author      : GitHub Copilot (MiniMax-M3)
-- Plan        : docs/audits/GAP_10_APPROVAL_WORKFLOW_PLAN.md
--
-- Adds 2 helper functions for the approval state machine:
--   1. fn_g10_approval_valid_transition(old, new)  -> bool
--      Pure function: returns true iff the state transition is allowed
--      by the documented state machine.  Used by application code AND
--      by the status update trigger (commit 3).
--
--   2. fn_g10_approval_compute_status(p_requestid)  -> text
--      STABLE: computes the expected status of a request from its
--      current actions.  Called by the status update trigger.
--
-- Conventions
--   - CREATE OR REPLACE FUNCTION  (idempotent, re-runnable)
--   - No BEGIN/COMMIT            (no DDL is transaction-safe in our pattern)
--   - STABLE for query functions (optimizer can cache results)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. fn_g10_approval_valid_transition
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g10_approval_valid_transition(
    p_old_status text,
    p_new_status text
)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $fn$
BEGIN
    -- Identity: no-op transitions are always valid (trigger may fire on no-op)
    IF p_old_status = p_new_status THEN
        RETURN true;
    END IF;

    -- Allow NULL -> X (initial set) for any valid X
    IF p_old_status IS NULL THEN
        RETURN p_new_status IN ('PENDING', 'IN_REVIEW');
    END IF;

    -- From PENDING
    IF p_old_status = 'PENDING' THEN
        RETURN p_new_status IN ('IN_REVIEW', 'CANCELLED', 'EXPIRED');
    END IF;

    -- From IN_REVIEW (the active state machine)
    IF p_old_status = 'IN_REVIEW' THEN
        RETURN p_new_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED', 'PENDING');
        -- 'PENDING' is reachable from IN_REVIEW via RETURNED action
    END IF;

    -- Terminal states: nothing else is allowed
    IF p_old_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED') THEN
        RETURN false;
    END IF;

    -- Unknown old status
    RETURN false;
END;
$fn$;

-- ---------------------------------------------------------------------
-- 2. fn_g10_approval_compute_status
--    Reads the latest action for the request and returns the expected
--    status.  Falls back to the request's current status if no actions
--    exist (defensive).
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g10_approval_compute_status(
    p_requestid bigint
)
RETURNS text
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    v_current_status   varchar(20);
    v_latest_action    varchar(20);
    v_rejected_count   int;
    v_approved_count   int;
    v_total_levels     int;
    v_required_approved int;
    v_approval_complete boolean;
BEGIN
    -- 1. Defensive: read current status (always present on the row)
    SELECT status, totallevels
      INTO v_current_status, v_total_levels
      FROM public.tblapprovalrequests
     WHERE requestid = p_requestid;

    IF v_current_status IS NULL THEN
        RETURN NULL;
    END IF;

    -- 2. Terminal states: never recompute
    IF v_current_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED') THEN
        RETURN v_current_status;
    END IF;

    -- 3. Most recent action
    SELECT actiontype INTO v_latest_action
      FROM public.tblapprovalactions
     WHERE requestid = p_requestid
     ORDER BY actiondate DESC
     LIMIT 1;

    -- 4. Counts
    SELECT
        count(*) FILTER (WHERE actiontype = 'APPROVED'),
        count(*) FILTER (WHERE actiontype = 'REJECTED')
      INTO v_approved_count, v_rejected_count
      FROM public.tblapprovalactions
     WHERE requestid = p_requestid;

    -- 5. Use the existing function to check completion
    v_approval_complete := public.isapprovalcomplete(p_requestid);

    -- 6. Compute
    IF v_rejected_count > 0 THEN
        RETURN 'REJECTED';
    END IF;

    IF v_approval_complete THEN
        RETURN 'APPROVED';
    END IF;

    -- From PENDING, any action moves to IN_REVIEW
    IF v_current_status = 'PENDING' AND v_latest_action IS NOT NULL THEN
        RETURN 'IN_REVIEW';
    END IF;

    -- Default: keep current status
    RETURN v_current_status;
END;
$fn$;

-- ---------------------------------------------------------------------
-- Grants (least-privilege)
-- ---------------------------------------------------------------------
GRANT EXECUTE ON FUNCTION public.fn_g10_approval_valid_transition(text, text) TO app_admin;
GRANT EXECUTE ON FUNCTION public.fn_g10_approval_compute_status(bigint)       TO app_admin, app_readwrite, app_auditor;

-- ---------------------------------------------------------------------
-- Idempotency signature (Part A)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g10_approval_signature_part_a()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP10-APPROVAL-PART-A-2026-06-11-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g10_approval_signature_part_a() TO PUBLIC;

-- =====================================================================
-- End of IntegratedAccSys_Approval_fn.sql (Part A)
-- Next commit (Part B) will add the 2 triggers.
-- =====================================================================
