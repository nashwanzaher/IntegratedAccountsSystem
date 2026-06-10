-- =====================================================================
-- IntegratedAccSys — Constraints Baseline (Gap #4) — Part A
-- =====================================================================
-- Date        : 2026-06-11
-- Branch      : feat/gap-4-constraints
-- Author      : GitHub Copilot (MiniMax-M3)
-- Plan        : docs/audits/GAP_4_CONSTRAINTS_PLAN.md
--
-- This file is the FIRST install step of Gap #4. It installs
-- btree_gist (required for EXCLUDE USING gist on scalar + range
-- combinations) and nothing else.
--
-- Why btree_gist?
-- ---------------
-- The default operator class for `=` on int/timestamp/text is
-- btree. But the EXCLUDE syntax requires a single GiST index to
-- span multiple columns with mixed operators (e.g. `=` AND `&&`).
-- btree_gist adds btree-equality operators to the GiST framework
-- so the planner can build a single combined GiST index.
--
-- After this commit:
--   - btree_gist 1.5 (or current default version) is installed.
--   - No CHECK, EXCLUDE, or trigger is added yet (those come in
--     the next commits of this same branch, each its own commit).
--   - Idempotent: re-running is a no-op.
-- =====================================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'btree_gist') THEN
        CREATE EXTENSION btree_gist;
        RAISE NOTICE '[OK] btree_gist installed.';
    ELSE
        RAISE NOTICE '[..] btree_gist already installed.';
    END IF;
END
$$;

-- Idempotency signature (used by audit-g4-constraints.ps1)
CREATE OR REPLACE FUNCTION public.fn_g4_constraints_signature_part_a()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP4-CONSTRAINTS-PART-A-2026-06-11-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g4_constraints_signature_part_a() TO PUBLIC;

-- =====================================================================
-- End of IntegratedAccSys_Constraints.sql (Part A)
-- Next commits will add CHECK and EXCLUDE constraints in this same file
-- (or a Part B file) — one commit per concern, per the plan.
-- =====================================================================
