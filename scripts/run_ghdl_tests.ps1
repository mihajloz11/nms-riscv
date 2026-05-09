param(
    [ValidateSet("all", "alu", "zbb", "extended", "rv32i")]
    [string]$Scenario = "all"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $repoRoot

if (-not (Get-Command ghdl -ErrorAction SilentlyContinue)) {
    throw "GHDL nije nadjen u PATH-u. Instaliraj GHDL ili dodaj ghdl.exe u PATH."
}

$workDir = ".\tmp\ghdl"
New-Item -ItemType Directory -Force -Path $workDir | Out-Null
Get-ChildItem -LiteralPath $workDir -Force -ErrorAction SilentlyContinue | Remove-Item -Force

function Invoke-Ghdl {
    $ghdlArgs = $args
    & ghdl @ghdlArgs
    if ($LASTEXITCODE -ne 0) {
        throw "GHDL komanda nije prosla: ghdl $($ghdlArgs -join ' ')"
    }
}

$sourceFiles = @(
    ".\rv32i\paketi\txt_util.vhd",
    ".\rv32i\paketi\alu_ops_pkg.vhd",
    ".\rv32i\podaci\ALU_simple.vhd",
    ".\rv32i\podaci\register_bank.vhd",
    ".\rv32i\podaci\immediate.vhd",
    ".\rv32i\podaci\podaci.vhd",
    ".\rv32i\kontrola\ctrl_decoder.vhd",
    ".\rv32i\kontrola\alu_decoder.vhd",
    ".\rv32i\kontrola\kontrola.vhd",
    ".\rv32i\TOP_RISCV.vhd",
    ".\rv32i\testovi\BRAM_byte_addressable.vhd",
    ".\rv32i\testovi\ALU_zbb_tb.vhd",
    ".\rv32i\testovi\TOP_testovi.vhd"
)

foreach ($file in $sourceFiles) {
    Invoke-Ghdl -a --std=08 "--workdir=$workDir" $file
}

if ($Scenario -eq "all" -or $Scenario -eq "alu") {
    Invoke-Ghdl -e --std=08 "--workdir=$workDir" ALU_zbb_tb
    Invoke-Ghdl -r --std=08 "--workdir=$workDir" ALU_zbb_tb
}

if ($Scenario -ne "alu") {
    Invoke-Ghdl -e --std=08 "--workdir=$workDir" TOP_testovi
}

if ($Scenario -eq "all" -or $Scenario -eq "zbb") {
    Invoke-Ghdl -r --std=08 "--workdir=$workDir" TOP_testovi `
        -gSCENARIO_ID_G=1 `
        -gPROGRAM_PATH_G="rv32i/testovi/test_programi/zbb_demo.txt" `
        --stop-time=80us
}

if ($Scenario -eq "all" -or $Scenario -eq "extended") {
    Invoke-Ghdl -r --std=08 "--workdir=$workDir" TOP_testovi `
        -gSCENARIO_ID_G=2 `
        -gPROGRAM_PATH_G="rv32i/testovi/test_programi/extended_demo.txt" `
        --stop-time=80us
}

if ($Scenario -eq "all" -or $Scenario -eq "rv32i") {
    Invoke-Ghdl -r --std=08 "--workdir=$workDir" TOP_testovi `
        -gSCENARIO_ID_G=0 `
        -gPROGRAM_PATH_G="rv32i/testovi/test_programi/rv32i_regression.txt" `
        --stop-time=80us
}

Write-Host "Svi trazeni GHDL testovi su prosli."
