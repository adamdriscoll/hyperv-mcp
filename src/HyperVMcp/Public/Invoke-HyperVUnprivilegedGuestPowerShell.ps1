function Invoke-HyperVUnprivilegedGuestPowerShell {
    <#
    .SYNOPSIS
    Run PowerShell in a VM as the configured unprivileged guest account.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $Script,

        [ValidateRange(1, 2147483647)]
        [int] $TimeoutMilliseconds = 60000
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    Assert-HyperVValue -Value $Script -Name 'script'
    try {
        $credential = New-HyperVGuestCredential -Unprivileged
        $result = Invoke-HyperVGuestScriptInternal -VMName $VMName -Script $Script -Credential $credential -TimeoutMs $TimeoutMilliseconds
        ConvertTo-HyperVMcpJson -InputObject $result
    }
    catch {
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $false; error = $_.Exception.Message })
    }
}
