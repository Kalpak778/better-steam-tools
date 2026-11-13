# Better Steam Tools 1.0.9 - download and unpack for review
$ErrorActionPreference = 'Stop'
$repo = 'https://raw.githubusercontent.com/Kalpak778/better-steam-tools/main'
$archive = 'Better Steam Tools 1.0.9.zip'
$url = "$repo/$([uri]::EscapeDataString($archive))"
$destination = Join-Path $env:USERPROFILE 'Downloads\Better-Steam-Tools-1.0.9'
$zip = Join-Path $env:TEMP ('bst-' + [guid]::NewGuid().ToString('N') + '.zip')
try {
    Write-Host 'Downloading Better Steam Tools 1.0.9...'
    Invoke-WebRequest -Uri $url -OutFile $zip
    $sha256 = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
    Write-Host "Downloaded SHA256: $sha256"
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Expand-Archive -LiteralPath $zip -DestinationPath $destination -Force
    Write-Host "Files extracted to: $destination" -ForegroundColor Green
    Write-Host 'No DLL files have been installed or executed.'
} finally {
    Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
}
