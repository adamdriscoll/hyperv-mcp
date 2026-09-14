function hyperv_unprivileged_run_ps {
    <#
    .SYNOPSIS
    Run PowerShell in a VM as the configured unprivileged guest account.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [Parameter(Mandatory)]
        [string] $script,

        [ValidateRange(1, 2147483647)]
        [int] $timeout_ms = 60000
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    Assert-HyperVValue -Value $script -Name 'script'
    try {
        $credential = New-HyperVGuestCredential -Unprivileged
        $result = Invoke-HyperVGuestScriptInternal -VMName $vm_name -Script $script -Credential $credential -TimeoutMs $timeout_ms
        ConvertTo-HyperVMcpJson -InputObject $result
    }
    catch {
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $false; error = $_.Exception.Message })
    }
}
