function ConvertTo-HyperVPowerShellLiteral {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Value
    )

    "'$($Value.Replace("'", "''"))'"
}
