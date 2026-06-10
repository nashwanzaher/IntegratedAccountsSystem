# CodeGPT API Key helper scripts

Files:

- `set-codegpt-api-key.ps1` — prompts securely for the API key, sets it in the
  current PowerShell session and persists it for the current user via `setx`.

- `remove-codegpt-api-key.ps1` — removes the key from the current session and
  clears the persisted user environment value.

Usage:

PowerShell (run from repository root):

```powershell
.\scripts\set-codegpt-api-key.ps1
```

Then restart VS Code or any open shells to pick up the new user environment variable.

To remove the key:

```powershell
.\scripts\remove-codegpt-api-key.ps1
```

Security note:

- Do not paste exposed or previously leaked keys. Revoke any compromised key
  and generate a new one before using these scripts.
- Prefer using your extension's secure storage (Command Palette) when available.
