param(
    [string] $DeviceId
)

. "$PSScriptRoot\common.ps1"

Push-Location (Join-Path $PSScriptRoot '..')
try {
    $dartDefines = Get-DartDefineArgs '.\.env'

    if ($DeviceId) {
        $args = @('run', '-d', $DeviceId) + $dartDefines
        Invoke-Flutter @args
    }
    else {
        $args = @('run') + $dartDefines
        Invoke-Flutter @args
    }
}
finally {
    Pop-Location
}
