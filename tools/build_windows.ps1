param(
    [string]$GodotPath = 'C:\Program Files (x86)\Godot\Godot_v4.7.2-stable_win64.exe'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$outputRoot = Join-Path $projectRoot 'builds/windows'
$runtimeRoot = Join-Path $projectRoot '.runtime/windows-build'
New-Item -ItemType Directory -Force -Path $outputRoot, $runtimeRoot | Out-Null
$executable = Join-Path $outputRoot 'HotelEmpire.exe'

function Invoke-CheckedGame([string]$Binary, [string[]]$Arguments, [string]$Log, [string]$WorkingDirectory) {
    $quotedArguments = $Arguments | ForEach-Object { '"' + $_ + '"' }
    $process = Start-Process -FilePath $Binary -ArgumentList $quotedArguments -WorkingDirectory $WorkingDirectory -WindowStyle Hidden -PassThru
    if (-not $process.WaitForExit(60000)) {
        $process.Kill()
        throw "Timed out: $Binary. Inspect $Log"
    }
    if ($process.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $Log)) { throw "Process failed: $Binary. Inspect $Log" }
    if (Select-String -LiteralPath $Log -Pattern 'SCRIPT ERROR:|^ERROR:|leaked at exit|resources still in use' -Quiet) { throw "Runtime errors: $Log" }
}

$exportLog = Join-Path $runtimeRoot 'export.log'
Invoke-CheckedGame $GodotPath @('--headless', '--path', $projectRoot, '--export-release', 'Windows Desktop', $executable, '--log-file', $exportLog) $exportLog $projectRoot
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = Join-Path $runtimeRoot 'user-data'
    New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
    $bootLog = Join-Path $runtimeRoot 'boot.log'
    Invoke-CheckedGame $executable @('--quit-after', '120', '--log-file', $bootLog) $bootLog $outputRoot
    $smokeLog = Join-Path $runtimeRoot 'smoke.log'
    Invoke-CheckedGame $executable @('--log-file', $smokeLog, '--', '--release-smoke') $smokeLog $outputRoot
    $reportPath = Join-Path $env:APPDATA 'Godot/app_userdata/Hotel Empire/release-smoke-report.json'
    $report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
    if ($report.failures -ne 0 -or $report.ticks -ne 6120) { throw 'Packaged gameplay smoke failed' }
} finally {
    $env:APPDATA = $previousAppData
}

foreach ($name in @('LICENSE-GODOT.txt', 'THIRD-PARTY-NOTICES.txt', 'LEIA-ME.txt')) {
    Copy-Item -LiteralPath (Join-Path $projectRoot "docs/release/$name") -Destination (Join-Path $outputRoot $name)
}
$revision = (git -C $projectRoot rev-parse HEAD).Trim()
$manifest = [ordered]@{
    createdUtc = [DateTime]::UtcNow.ToString('o')
    gitRevision = $revision
    sourceDirty = [bool](git -C $projectRoot status --porcelain)
    platform = 'Windows x86_64'
    executableSha256 = (Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash.ToLowerInvariant()
    executableBytes = (Get-Item -LiteralPath $executable).Length
    smoke = $report
}
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $outputRoot 'build-manifest.json') -Encoding utf8
$archive = Join-Path $projectRoot 'builds/HotelEmpire-windows-x86_64.zip'
$packageFiles = @('HotelEmpire.exe','LICENSE-GODOT.txt','THIRD-PARTY-NOTICES.txt','LEIA-ME.txt','build-manifest.json') | ForEach-Object { Join-Path $outputRoot $_ }
Compress-Archive -LiteralPath $packageFiles -DestinationPath $archive -Force
Write-Output "Verified package: $archive"
Get-FileHash -LiteralPath $archive -Algorithm SHA256
