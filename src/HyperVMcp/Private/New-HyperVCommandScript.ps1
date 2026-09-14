function New-HyperVCommandScript {
    param(
        [Parameter(Mandatory)]
        [string] $Command,

        [AllowNull()]
        [string[]] $Args,

        [AllowNull()]
        [string] $Cwd
    )

    $argumentLiterals = @($Args | ForEach-Object { ConvertTo-HyperVPowerShellLiteral -Value $_ })
    $invocation = "& $(ConvertTo-HyperVPowerShellLiteral -Value $Command)"
    if ($argumentLiterals.Count -gt 0) {
        $invocation += " $($argumentLiterals -join ' ')"
    }

    if ([string]::IsNullOrWhiteSpace($Cwd)) {
        return "$invocation`nexit `$LASTEXITCODE"
    }

    @"
Push-Location $(ConvertTo-HyperVPowerShellLiteral -Value $Cwd)
try {
    $invocation
}
finally {
    Pop-Location
}
exit `$LASTEXITCODE
"@
}
