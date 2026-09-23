param([string]$ArchivePath = '')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
if (-not $ArchivePath) { $ArchivePath = Join-Path $projectRoot 'builds/HotelEmpire-windows-x86_64.zip' }
$kitRoot = Join-Path $projectRoot ('builds/compatibility-kit/' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $kitRoot -Force | Out-Null
Copy-Item -LiteralPath $ArchivePath -Destination (Join-Path $kitRoot 'HotelEmpire-windows-x86_64.zip')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'test_windows_package.ps1') -Destination (Join-Path $kitRoot 'Validate-Package.ps1')
Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/release/external-validation.ps1') -Destination (Join-Path $kitRoot 'Start-Validation.ps1')
Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/release/EXTERNAL-TEST.txt') -Destination (Join-Path $kitRoot 'LEIA-ME.txt')
Get-FileHash -LiteralPath (Join-Path $kitRoot 'HotelEmpire-windows-x86_64.zip') -Algorithm SHA256 |
    Select-Object Algorithm,Hash | ConvertTo-Json | Set-Content (Join-Path $kitRoot 'package-hash.json') -Encoding utf8
$destination = Join-Path $projectRoot 'builds/HotelEmpire-compatibility-kit.zip'
Compress-Archive -Path (Join-Path $kitRoot '*') -DestinationPath $destination -Force
Write-Output "Compatibility kit: $destination"
