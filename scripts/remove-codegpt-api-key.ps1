<#
Remove CodeGPT / OpenAI API key from current session and clear persisted user value.

Usage:
  .\scripts\remove-codegpt-api-key.ps1
#>

# Remove from current session if present
Try {
    Remove-Item Env:\OPENAI_API_KEY -ErrorAction SilentlyContinue
} Catch {
    # ignore
}

# Clear persisted user environment variable (sets to empty string)
setx OPENAI_API_KEY "" | Out-Null

Write-Host "API key removed from current session and cleared from user environment." -ForegroundColor Cyan

exit 0
