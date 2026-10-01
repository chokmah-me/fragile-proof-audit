# One-command campaign verify: Lean forge + Python gates.
# Usage (from repo root):  pwsh ./scripts/verify.ps1 [-Skip ab_fluid]
# Exit nonzero if either half fails.
#
# -Skip names a comma-separated list of gate keys to skip (default: ab_fluid,
# the hours-long Euler interval replay, which runs in the deep-replay
# workflow instead — mirrors verify.yml's `check.py --skip ab_fluid`).

param(
    [string]$Skip = "ab_fluid"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

New-Item -ItemType Directory -Force -Path (Join-Path $Root "results") | Out-Null

Write-Host "=== Python gates ===" -ForegroundColor Cyan
$gateArgs = @()
if ($Skip -ne "") {
    $gateArgs += "--skip"
    $gateArgs += $Skip
}
python (Join-Path $Root "scripts\gates\check.py") @gateArgs
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
