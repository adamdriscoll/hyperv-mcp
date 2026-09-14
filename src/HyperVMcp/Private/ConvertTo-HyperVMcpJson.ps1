function ConvertTo-HyperVMcpJson {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object] $InputObject,

        [int] $Depth = 8
    )

    ConvertTo-Json -InputObject $InputObject -Depth $Depth -Compress
}
