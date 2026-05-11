param(
    [ValidateSet("all", "synth", "alu", "zbb", "extended", "rv32i")]
    [string]$Scenario = "all"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$vivadoBat = "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat"
$tclScript = Join-Path $PSScriptRoot "vivado_run_checks.tcl"

if (-not (Test-Path -LiteralPath $vivadoBat)) {
    throw "Vivado nije nadjen na ocekivanoj putanji: $vivadoBat"
}

Push-Location $repoRoot
try {
    & $vivadoBat -mode batch -source $tclScript -tclargs $Scenario
    if ($LASTEXITCODE -ne 0) {
        throw "Vivado batch provjera nije prosla."
    }
}
finally {
    Pop-Location
}

Write-Host "Vivado batch provjere su zavrsene."
