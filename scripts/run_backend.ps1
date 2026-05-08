param(
    [string] $HostAddress = '0.0.0.0',
    [int] $Port = 8080
)

Push-Location (Join-Path $PSScriptRoot '..\backend')
try {
    python -m uvicorn app.main:app --reload --host $HostAddress --port $Port
}
finally {
    Pop-Location
}
