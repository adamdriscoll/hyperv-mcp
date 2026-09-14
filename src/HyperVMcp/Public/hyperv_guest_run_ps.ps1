function hyperv_guest_run_ps {
    <#
    .SYNOPSIS
    Run a PowerShell script inside a VM through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [Parameter(Mandatory)]
        [string] $script,

        [ValidateRange(1, 2147483647)]
        [int] $timeout_ms = 60000,

        [bool] $elevated = $false,

        [AllowEmptyString()]
        [string] $username = '',

        [AllowEmptyString()]
        [string] $password = ''
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    Assert-HyperVValue -Value $script -Name 'script'
    try {
        $credential = New-HyperVGuestCredential -Username $username -Password $password
        $result = Invoke-HyperVGuestScriptInternal -VMName $vm_name -Script $script -Credential $credential -TimeoutMs $timeout_ms -Elevated $elevated
        ConvertTo-HyperVMcpJson -InputObject $result
    }
    catch {
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $false; error = $_.Exception.Message })
    }
}
