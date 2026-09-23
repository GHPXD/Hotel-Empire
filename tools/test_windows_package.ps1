param(
    [string]$ArchivePath = '',
    [string]$OutputRoot = ''
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
if (-not $ArchivePath) { $ArchivePath = Join-Path $projectRoot 'builds/HotelEmpire-windows-x86_64.zip' }
if (-not $OutputRoot) { $OutputRoot = Join-Path $projectRoot '.runtime/package-matrix' }
$runRoot = Join-Path $OutputRoot ([DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0,8))
$extractRoot = Join-Path $runRoot 'Hotel Empire extraido'
New-Item -ItemType Directory -Force -Path $extractRoot | Out-Null
# Only expected top-level files may enter the package. Validate before extraction.
$expected = @('HotelEmpire.exe','LEIA-ME.txt','LICENSE-GODOT.txt','THIRD-PARTY-NOTICES.txt','build-manifest.json')
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead([IO.Path]::GetFullPath($ArchivePath))
try {
    $names = @($zip.Entries | ForEach-Object { $_.FullName })
    if ($names.Count -ne $expected.Count -or (Compare-Object ($names | Sort-Object) ($expected | Sort-Object))) { throw 'Unexpected package contents' }
} finally { $zip.Dispose() }
Expand-Archive -LiteralPath $ArchivePath -DestinationPath $extractRoot
$executable = Join-Path $extractRoot 'HotelEmpire.exe'
$manifest = Get-Content -LiteralPath (Join-Path $extractRoot 'build-manifest.json') -Raw | ConvertFrom-Json
if ((Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash.ToLowerInvariant() -ne $manifest.executableSha256) { throw 'Extracted executable hash mismatch' }
$reports = @()
$previousAppData = $env:APPDATA
try {
    foreach ($resolution in @('1024x640','1280x800','1600x900')) {
        foreach ($largeText in @($false,$true)) {
            $label = $resolution + $(if ($largeText) { '-large' } else { '-normal' })
            $caseRoot = Join-Path $runRoot $label
            $env:APPDATA = Join-Path $caseRoot 'user-data'
            New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
            $log = Join-Path $caseRoot 'runtime.log'
            $arguments = @('--resolution',$resolution,'--log-file',$log,'--','--release-smoke')
            if ($largeText) { $arguments += '--smoke-large-text' }
            $quoted = $arguments | ForEach-Object { '"' + $_ + '"' }
            $process = Start-Process -FilePath $executable -WorkingDirectory $extractRoot -ArgumentList $quoted -WindowStyle Hidden -PassThru
            if (-not $process.WaitForExit(60000)) { $process.Kill(); throw "Timeout: $label" }
            if ($process.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $log)) { throw "Execution failed: $label" }
            if (Select-String -LiteralPath $log -Pattern 'SCRIPT ERROR:|^ERROR:|leaked at exit|resources still in use' -Quiet) { throw "Runtime errors: $label" }
            $dataRoot = Join-Path $env:APPDATA 'Godot/app_userdata/Hotel Empire'
            $report = Get-Content -LiteralPath (Join-Path $dataRoot 'release-smoke-report.json') -Raw | ConvertFrom-Json
            if ($report.failures -ne 0 -or $report.presentation.large_text -ne $largeText) { throw "Smoke assertion failed: $label" }
            $capture = Join-Path $dataRoot 'release-smoke.png'
            if (-not (Test-Path -LiteralPath $capture)) { throw "Missing rendered capture: $label" }
            $reports += [ordered]@{ case = $label; requestedResolution = $resolution; report = $report; capture = $capture }
            Write-Output "Passed: $label"
        }
    }
} finally { $env:APPDATA = $previousAppData }
$result = [ordered]@{ archiveSha256 = (Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash.ToLowerInvariant(); executableSha256 = $manifest.executableSha256; sourceRevision = $manifest.gitRevision; sourceDirty = $manifest.sourceDirty; cases = $reports }
$result | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $runRoot 'matrix.json') -Encoding utf8
Write-Output "Matrix: $(Join-Path $runRoot 'matrix.json')"
