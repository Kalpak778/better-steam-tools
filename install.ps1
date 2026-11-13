$url = "https://raw.githubusercontent.com/Kalpak778/better-steam-tools/main/Better%20Steam%20Tools%201.0.9.zip"
$path = Join-Path $env:USERPROFILE "Downloads\Better Steam Tools 1.0.9.zip"

Invoke-WebRequest -Uri $url -OutFile $path -ErrorAction Stop

Write-Host "Downloaded: $path" -ForegroundColor Green
