#requires -Version 5.1
$ErrorActionPreference = 'Stop'
$runRoot = Join-Path $PSScriptRoot ('results/' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $runRoot -Force | Out-Null
$passed = $false
try {
    & (Join-Path $PSScriptRoot 'Validate-Package.ps1') -ArchivePath (Join-Path $PSScriptRoot 'HotelEmpire-windows-x86_64.zip') -OutputRoot $runRoot
    $passed = $true
} catch {
    $_ | Out-String | Set-Content -LiteralPath (Join-Path $runRoot 'failure.txt') -Encoding utf8
    Write-Host "Validation failed. Details: $runRoot"
} finally {
    $bundle = Join-Path $runRoot 'report'
    New-Item -ItemType Directory -Path $bundle -Force | Out-Null
    # Include test reports only; never bundle the extracted executable or personal saves.
    $failure = Join-Path $runRoot 'failure.txt'
    if (Test-Path -LiteralPath $failure) { Copy-Item -LiteralPath $failure -Destination $bundle }
    foreach ($matrixRoot in Get-ChildItem -LiteralPath $runRoot -Directory | Where-Object { $_.Name -ne 'report' }) {
        $matrix = Join-Path $matrixRoot.FullName 'matrix.json'
        if (Test-Path -LiteralPath $matrix) { Copy-Item -LiteralPath $matrix -Destination $bundle }
        foreach ($case in Get-ChildItem -LiteralPath $matrixRoot.FullName -Directory | Where-Object { $_.Name -match '^\d+x\d+-(normal|large)$' }) {
            $destination = Join-Path $bundle $case.Name
            New-Item -ItemType Directory -Path $destination -Force | Out-Null
            foreach ($relative in @('runtime.log', 'user-data/Godot/app_userdata/Hotel Empire/release-smoke-report.json', 'user-data/Godot/app_userdata/Hotel Empire/release-smoke.png', 'user-data/Godot/app_userdata/Hotel Empire/release-elevator-metrics.png')) {
                $source = Join-Path $case.FullName $relative
                if (Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination $destination }
            }
        }
    }
    @{ passed = $passed; powershell = $PSVersionTable.PSVersion.ToString() } | ConvertTo-Json |
        Set-Content -LiteralPath (Join-Path $bundle 'runner.json') -Encoding utf8
    $archive = Join-Path $runRoot 'HotelEmpire-test-results.zip'
    Compress-Archive -Path (Join-Path $bundle '*') -DestinationPath $archive
    Write-Host "Results: $archive"
}
if (-not $passed) { exit 1 }
