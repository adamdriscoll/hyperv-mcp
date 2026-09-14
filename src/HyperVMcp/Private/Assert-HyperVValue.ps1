function Assert-HyperVValue {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Value,

        [Parameter(Mandatory)]
        [string] $Name
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name is required"
    }
}
