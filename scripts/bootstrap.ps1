. "$PSScriptRoot\common.ps1"

Push-Location (Join-Path $PSScriptRoot '..')
try {
    Invoke-Flutter '--version'

    Invoke-Flutter 'pub' 'get'
}
finally {
    Pop-Location
}
