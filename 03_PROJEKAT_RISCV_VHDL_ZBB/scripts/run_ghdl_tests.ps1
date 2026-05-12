param(
    [ValidateSet("all", "alu", "zbb", "extended", "rv32i")]
    [string]$Scenario = "all"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $repoRoot

$outputDir = ".\output"
$workDir = ".\tmp\ghdl"
$logPath = ".\output\ghdl_latest.log"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
New-Item -ItemType Directory -Force -Path $workDir | Out-Null
Get-ChildItem -LiteralPath $workDir -Force -ErrorAction SilentlyContinue | Remove-Item -Force

if (-not (Get-Command ghdl -ErrorAction SilentlyContinue)) {
    throw "GHDL nije nadjen u PATH-u. Instaliraj GHDL ili dodaj ghdl.exe u PATH."
}

"GHDL provjera - scenario: $Scenario" | Set-Content -LiteralPath $logPath -Encoding UTF8
"Radni folder: root projekta" | Add-Content -LiteralPath $logPath -Encoding UTF8
"" | Add-Content -LiteralPath $logPath -Encoding UTF8

function Write-LogLine {
    param([string]$Line)
    Write-Host $Line
    [System.IO.File]::AppendAllText(
        $script:logPath,
        $Line + [System.Environment]::NewLine,
        [System.Text.UTF8Encoding]::new($false))
}

function Invoke-Ghdl {
    param([string[]]$GhdlArgs)

    Write-LogLine ""
    Write-LogLine ("ghdl " + ($GhdlArgs -join " "))
    & ghdl @GhdlArgs 2>&1 | ForEach-Object {
        $line = $_.ToString()
        Write-Host $line
        [System.IO.File]::AppendAllText(
            $script:logPath,
            $line + [System.Environment]::NewLine,
            [System.Text.UTF8Encoding]::new($false))
    }
    if ($LASTEXITCODE -ne 0) {
        throw "GHDL komanda nije prosla: ghdl $($GhdlArgs -join ' ')"
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
    Invoke-Ghdl -GhdlArgs @("-a", "--std=08", "--workdir=$workDir", $file)
}

if ($Scenario -eq "all" -or $Scenario -eq "alu") {
    Invoke-Ghdl -GhdlArgs @("-e", "--std=08", "--workdir=$workDir", "ALU_zbb_tb")
    Invoke-Ghdl -GhdlArgs @("-r", "--std=08", "--workdir=$workDir", "ALU_zbb_tb")
}

if ($Scenario -ne "alu") {
    Invoke-Ghdl -GhdlArgs @("-e", "--std=08", "--workdir=$workDir", "TOP_testovi")
}

if ($Scenario -eq "all" -or $Scenario -eq "zbb") {
    Invoke-Ghdl -GhdlArgs @(
        "-r", "--std=08", "--workdir=$workDir", "TOP_testovi",
        "-gSCENARIO_ID_G=1",
        "-gPROGRAM_PATH_G=rv32i/testovi/test_programi/zbb_demo.txt",
        "--stop-time=80us"
    )
}

if ($Scenario -eq "all" -or $Scenario -eq "extended") {
    Invoke-Ghdl -GhdlArgs @(
        "-r", "--std=08", "--workdir=$workDir", "TOP_testovi",
        "-gSCENARIO_ID_G=2",
        "-gPROGRAM_PATH_G=rv32i/testovi/test_programi/extended_demo.txt",
        "--stop-time=80us"
    )
}

if ($Scenario -eq "all" -or $Scenario -eq "rv32i") {
    Invoke-Ghdl -GhdlArgs @(
        "-r", "--std=08", "--workdir=$workDir", "TOP_testovi",
        "-gSCENARIO_ID_G=0",
        "-gPROGRAM_PATH_G=rv32i/testovi/test_programi/rv32i_regression.txt",
        "--stop-time=80us"
    )
}

Write-LogLine ""
Write-LogLine "Svi trazeni GHDL testovi su prosli."
Write-LogLine "Log je sacuvan u: output/ghdl_latest.log"
