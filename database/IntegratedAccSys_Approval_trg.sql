-- =====================================================================
-- IntegratedAccSys — Approval Workflow Triggers (Gap #10) — Part B
-- =====================================================================
-- Date        : 2026-06-11
-- Branch      : feat/gap-10-approval-workflow
-- Author      : GitHub Copilot (MiniMax-M3)
-- Plan        : docs/audits/GAP_10_APPROVAL_WORKFLOW_PLAN.md
--
-- Adds 2 AFTER INSERT triggers on tblapprovalactions that automate
-- the state machine:
--
--   1. trg_g10_approval_action_audit
--      After an action is inserted, log it to tblaudi_security
--      with the action id + event type + performed-by.
--
--   2. trg_g10_approval_request_status_update
--      After an action is inserted, recompute the request's expected
--      status using fn_g10_approval_compute_status() and update
--      tblapprovalrequests.status if the transition is valid.
--
-- IMPORTANT: the trigger FUNCTIONS are created BEFORE the triggers
-- (matches the standard SQL practice of defining before use, even
-- though PostgreSQL defers function resolution to fire time).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1a. Function for action audit
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g10_approval_action_audit_fn()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $fn$
BEGIN
    INSERT INTO public.tblaudi_security (event_type, event_payload, actor_role)
    VALUES (
        'APPROVAL_ACTION',
        jsonb_build_object(
            'actionid',      NEW.actionid,
            'requestid',     NEW.requestid,
            'levelid',       NEW.levelid,
            'approverid',    NEW.approverid,
            'actiontype',    NEW.actiontype,
            'oldstatus',     NEW.oldstatus,
            'newstatus',     NEW.newstatus,
            'fromlevel',     NEW.fromlevel,
            'tolevel',       NEW.tolevel,
            'delegatedto',   NEW.delegatedto,
            'ipaddress',     NEW.ipaddress
        ),
        current_user
    );
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'trg_g10_approval_action_audit failed for actionid=%: %',
                 NEW.actionid, SQLERRM;
    RETURN NEW;
END;
$fn$;

GRANT EXECUTE ON FUNCTION public.fn_g10_approval_action_audit_fn() TO app_admin;

-- 1b. The trigger itself
DROP TRIGGER IF EXISTS trg_g10_approval_action_audit ON public.tblapprovalactions;

CREATE TRIGGER trg_g10_approval_action_audit
    AFTER INSERT ON public.tblapprovalactions
    FOR EACH ROW
    WHEN (NEW.actionid IS NOT NULL)
    EXECUTE FUNCTION public.fn_g10_approval_action_audit_fn();

-- ---------------------------------------------------------------------
-- 2a. Function for status update
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g10_approval_request_status_update_fn()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $fn$
DECLARE
    v_current_status  varchar(20);
    v_new_status      varchar(20);
    v_completedate    timestamp;
BEGIN
    SELECT status INTO v_current_status
      FROM public.tblapprovalrequests
     WHERE requestid = NEW.requestid;

    IF v_current_status IS NULL THEN
        RETURN NEW;
    END IF;

    v_new_status := public.fn_g10_approval_compute_status(NEW.requestid);

    IF v_new_status IS NULL OR v_new_status = v_current_status THEN
        RETURN NEW;
    END IF;

    IF NOT public.fn_g10_approval_valid_transition(v_current_status, v_new_status) THEN
        RAISE WARNING 'trg_g10_approval_request_status_update: invalid transition %->% for requestid=%',
                     v_current_status, v_new_status, NEW.requestid;
        RETURN NEW;
    END IF;

    IF v_new_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED') THEN
        v_completedate := now();
    ELSE
        v_completedate := NULL;
    END IF;

    UPDATE public.tblapprovalrequests
       SET status       = v_new_status,
           completedate = COALESCE(completedate, v_completedate),
           completedby  = CASE
                               WHEN v_new_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED')
                                   THEN NEW.approverid
                               ELSE completedby
                           END
     WHERE requestid = NEW.requestid;

    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'trg_g10_approval_request_status_update failed for requestid=%: %',
                 NEW.requestid, SQLERRM;
    RETURN NEW;
END;
$fn$;

GRANT EXECUTE ON FUNCTION public.fn_g10_approval_request_status_update_fn() TO app_admin;

-- 2b. The trigger itself
DROP TRIGGER IF EXISTS trg_g10_approval_request_status_update ON public.tblapprovalactions;

CREATE TRIGGER trg_g10_approval_request_status_update
    AFTER INSERT ON public.tblapprovalactions
    FOR EACH ROW
    WHEN (NEW.requestid IS NOT NULL)
    EXECUTE FUNCTION public.fn_g10_approval_request_status_update_fn();

-- ---------------------------------------------------------------------
-- Idempotency signature (Part B)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g10_approval_signature_part_b()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP10-APPROVAL-PART-B-2026-06-11-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g10_approval_signature_part_b() TO PUBLIC;

-- =====================================================================
-- End of IntegratedAccSys_Approval_trg.sql (Part B)
-- Next commit will add the dashboard view.
-- =====================================================================
