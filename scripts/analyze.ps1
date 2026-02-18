. "$PSScriptRoot\common.ps1"

Push-Location (Join-Path $PSScriptRoot '..')
try {
    Invoke-Flutter 'analyze'
}
finally {
    Pop-Location
}
