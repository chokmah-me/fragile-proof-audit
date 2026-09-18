# One-command campaign verify: Lean forge + Python gates.
# Usage (from repo root):  pwsh ./scripts/verify.ps1
# Exit nonzero if either half fails.

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

New-Item -ItemType Directory -Force -Path (Join-Path $Root "results") | Out-Null

Write-Host "=== Python gates ===" -ForegroundColor Cyan
python (Join-Path $Root "scripts\gates\check.py")
if ($LASTEXITCODE -ne 0) {
    Write-Host "gates FAILED" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "=== Lean forge ===" -ForegroundColor Cyan
$forge = Join-Path $Root "scripts\forge\verify_lean_project.py"
if (-not (Test-Path $forge)) {
    Write-Host "missing $forge" -ForegroundColor Red
    exit 1
}
python $forge --project $Root --target FragileProofAudit
$forgeCode = $LASTEXITCODE

Write-Host "=== summary ===" -ForegroundColor Cyan
if ($forgeCode -ne 0) {
    Write-Host "Lean forge FAILED (exit $forgeCode)" -ForegroundColor Red
    exit $forgeCode
}
Write-Host "verify OK (gates + forge)" -ForegroundColor Green
exit 0
