<#
Set CodeGPT / OpenAI API key securely for the current user.

This script prompts for the API key securely (hidden input), sets it for the
current PowerShell session and stores it as a user environment variable using
`setx` so new shells will inherit it.

Usage:
  Open PowerShell and run:
    .\scripts\set-codegpt-api-key.ps1

Security:
  - Do NOT pass the key as a plain argument to this script.
  - Revoke any exposed keys immediately and generate a new one before using.
#>

Write-Host "Enter your CodeGPT / OpenAI API key (input will be hidden):"
$secure = Read-Host -AsSecureString
if (-not $secure) {
    Write-Host "No input received. Aborting." -ForegroundColor Yellow
    exit 1
}

$ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
$apikey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)

# Save to current session
$env:OPENAI_API_KEY = $apikey

# Persist for the current user so new shells will get it
setx OPENAI_API_KEY "$apikey" | Out-Null

Write-Host "API key saved to user environment."
Write-Host "Note: restart any open terminals/VS Code windows to pick up the new value." -ForegroundColor Cyan

exit 0
