# Pull Request

## Summary

<!-- One-paragraph description of what this PR does. -->

## Type of change

- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New feature (non-breaking change that adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to change)
- [ ] 📚 Documentation update
- [ ] 🧹 Chore / refactor (no functional change)
- [ ] 🗄️ Database migration

## Related issues

<!-- Link any related issues: `Closes #123`, `Refs #456` -->

## Testing

- [ ] `dotnet build IntegratedAccSys.sln -c Release` → 0 errors, 0 warnings
- [ ] `dotnet run --project tests/IntegratedAccSys.DAL.DbTest -c Release` → 46/46 PASS
- [ ] Audit scripts pass (if applicable): `audit-g2`, `audit-g3`, `audit-g4`, `audit-g5`, `audit-g7`, `audit-g10`
- [ ] Manual smoke test of affected workflow (describe below)

### Test plan

<!-- Describe the manual tests you ran. -->

## Architecture

- [ ] PL → BL → DAL only (no skipped layers)
- [ ] No new architectural violations
- [ ] Naming conventions followed (see `docs/CONVENTIONS.md`)

## Database changes

- [ ] No DB changes
- [ ] Schema changes documented
- [ ] Migration script added under `database/migrations/`
- [ ] Pre-migration backup taken (for risky changes)
- [ ] Build green after applying migration on a fresh DB

## Documentation

- [ ] Code has XML doc comments on public API
- [ ] `docs/` updated (if applicable)
- [ ] CHANGELOG.md updated (if user-facing)

## Checklist

- [ ] My code follows the project's naming conventions
- [ ] I have performed a self-review
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix/feature works
- [ ] Any dependent changes have been merged and published

## Screenshots / SQL output

<!-- Add screenshots, ER diagrams, or psql output here if relevant. -->
