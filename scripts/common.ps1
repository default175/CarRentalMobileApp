Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-FlutterCommand {
    $candidates = @(
        @(
            (Get-Command flutter -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue),
            "$env:USERPROFILE\flutter\bin\flutter.bat",
            "$env:USERPROFILE\development\flutter\bin\flutter.bat",
            "C:\src\flutter\bin\flutter.bat"
        ) | Where-Object { $_ -and (Test-Path $_) }
    )

    if ($candidates.Count -gt 0) {
        return $candidates[0]
    }

    throw "Flutter SDK not found. Install Flutter and add it to PATH, or place it in a standard directory."
}

function Invoke-Flutter {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]] $Args
    )

    $flutter = Resolve-FlutterCommand
    & $flutter @Args
}

function Get-DartDefineArgs {
    param(
        [string] $EnvFilePath
    )

    if (-not (Test-Path $EnvFilePath)) {
        return @()
    }

    $args = @()

    foreach ($line in Get-Content $EnvFilePath) {
        $trimmed = $line.Trim()

        if (-not $trimmed -or $trimmed.StartsWith('#')) {
            continue
        }

        $parts = $trimmed -split '=', 2
        if ($parts.Count -ne 2) {
            continue
        }

        $key = $parts[0].Trim()
        $value = $parts[1].Trim()

        if (-not $key -or -not $value -or $value -eq 'replace_me') {
            continue
        }

        $args += '--dart-define'
        $args += "$key=$value"
    }

    return $args
}
