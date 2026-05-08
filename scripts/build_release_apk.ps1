param(
    [switch] $BackendEnabled
)

. "$PSScriptRoot\common.ps1"

Push-Location (Join-Path $PSScriptRoot '..')
try {
    $dartDefines = Get-DartDefineArgs '.\.env'

    if (-not $BackendEnabled) {
        $dartDefines += '--dart-define'
        $dartDefines += 'ENABLE_BACKEND_API=false'
    }

    $args = @('build', 'apk', '--release') + $dartDefines
    Invoke-Flutter @args
}
finally {
    Pop-Location
}
