# Better Steam Tools 1.0.9 - installer/updater
$ErrorActionPreference = 'Stop'
$archiveUrl = 'https://raw.githubusercontent.com/Kalpak778/better-steam-tools/main/Better%20Steam%20Tools%201.0.9.zip'
$expectedHash = '04FF4EC4EEFC2D2FDD956923401CF13EE0355EE48D8CD9DA89E7CA9AE2AA4C46'
$required = @('dwmapi.dll','xinput1_4.dll','OpenSteamTool.dll')
$tempDir = Join-Path ([IO.Path]::GetTempPath()) ('bst-' + [guid]::NewGuid().ToString('N'))
$archive = Join-Path $tempDir 'release.zip'
$extract = Join-Path $tempDir 'extracted'
try {
    $steam = $null
    foreach ($reg in @('HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam')) {
        if (Test-Path $reg) {
            $p = Get-ItemProperty $reg
            foreach ($candidate in @($p.SteamPath, $p.InstallPath)) {
                if ($candidate -and (Test-Path (Join-Path $candidate 'steam.exe'))) { $steam = (Resolve-Path $candidate).Path; break }
            }
        }
        if ($steam) { break }
    }
    if (-not $steam) { throw 'Steam not found. Please install Steam first.' }
    if (Get-Process -Name steam,steamwebhelper -ErrorAction SilentlyContinue) {
        throw 'Close Steam completely (including system tray), then retry.'
    }
    New-Item -ItemType Directory -Path $tempDir,$extract -Force | Out-Null
    Write-Host 'Downloading Better Steam Tools 1.0.9...'
    Invoke-WebRequest -Uri $archiveUrl -OutFile $archive -UseBasicParsing
    $actualHash = (Get-FileHash $archive -Algorithm SHA256).Hash
    if ($actualHash -ne $expectedHash) { throw "Archive SHA256 mismatch. Expected $expectedHash, got $actualHash" }
    Expand-Archive -LiteralPath $archive -DestinationPath $extract -Force
    $files = @{}
    foreach ($name in $required) {
        $matches = @(Get-ChildItem -LiteralPath $extract -File -Recurse | Where-Object Name -EQ $name)
        if ($matches.Count -ne 1) { throw "Expected exactly one $name in ZIP; found $($matches.Count)." }
        $files[$name] = $matches[0].FullName
    }
    Write-Host "Steam folder: $steam"
    Write-Host 'Backing up and updating the 3 DLL files...'
    $backup = Join-Path $steam ('bst-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Path $backup -Force | Out-Null
    foreach ($name in $required) {
        $target = Join-Path $steam $name
        if (Test-Path -LiteralPath $target) { Copy-Item -LiteralPath $target -Destination (Join-Path $backup $name) -Force }
    }
    foreach ($name in $required) { Copy-Item -LiteralPath $files[$name] -Destination (Join-Path $steam $name) -Force }
    New-Item -ItemType Directory -Path (Join-Path $steam 'config\stplug-in') -Force | Out-Null
    Write-Host "Installed v1.0.9 in $steam" -ForegroundColor Green
    Write-Host "Backup (previous DLLs, if any): $backup"
} catch {
    throw "Installation failed: $($_.Exception.Message)"
} finally {
    if (Test-Path -LiteralPath $tempDir) { Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
}
