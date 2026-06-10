$file = "d:\source\IntegratedAccountsSystem\tests\IntegratedAccSys.DAL.DbTest\Program.cs"
$content = Get-Content $file -Raw

# Inject PHASE 4 dimension tests right after Transaction lifecycle
$old = @"
                // Transaction lifecycle
                ctx.BeginTransaction();
                ctx.RollbackTransaction();
                Console.WriteLine("[OK] Transaction lifecycle.");
                passed++;
            }"@

$new = @"
                // Transaction lifecycle
                ctx.BeginTransaction();
                ctx.RollbackTransaction();
                Console.WriteLine("[OK] Transaction lifecycle.");
                passed++;

                // ==================== PHASE 4: DIMENSION ENGINE ====================
                Console.WriteLine();
                Console.WriteLine("[PHASE 4: COST CENTERS & DIMENSIONS]");

                // Dimension master reads (returns empty on fresh DB, but exercises wiring)
                RunNoParams(ctx, "getAllDepartments",   ref passed, ref failed);
                RunNoParams(ctx, "getAllProjects",      ref passed, ref failed);
                RunNoParams(ctx, "getAllBusinessUnits", ref passed, ref failed);
                RunNoParams(ctx, "getAllSegments",      ref passed, ref failed);
                RunNoParams(ctx, "getAllProfitCenters", ref passed, ref failed);
                RunNoParams(ctx, "vw_dimensions_summary", ref passed, ref failed);

                // Cross-dim analytics
                RunWithParams(ctx, "validateDimension", () => new NpgsqlParameter[] {
                    new NpgsqlParameter("p_dimtype", NpgsqlDbType.Varchar) { Value = "DEPARTMENT" },
                    new NpgsqlParameter("p_dimcode", NpgsqlDbType.Integer) { Value = DBNull.Value }
                }, ref passed, ref failed);
                RunNoParams(ctx, "getDimensionFullPath", ref passed, ref failed);

                // Dimension integration views
                RunNoParams(ctx, "vw_journalbody_with_dimensions", ref passed, ref failed);
                RunNoParams(ctx, "vw_bond_with_dimensions",         ref passed, ref failed);
                RunNoParams(ctx, "vw_treasury_with_dimensions",     ref passed, ref failed);
                RunNoParams(ctx, "vw_budgetvsactual_by_dimension",  ref passed, ref failed);
                RunNoParams(ctx, "vw_costcenter_hierarchy",         ref passed, ref failed);
                RunNoParams(ctx, "vw_dimension_usage",              ref passed, ref failed);
            }"@

if ($content.Contains($old)) {
    $content = $content.Replace($old, $new)
    Write-Host "DbTest updated successfully"
} else {
    Write-Host "Pattern not found in DbTest"
}

Set-Content -Path $file -Value $content -NoNewline
Write-Host "File saved"
