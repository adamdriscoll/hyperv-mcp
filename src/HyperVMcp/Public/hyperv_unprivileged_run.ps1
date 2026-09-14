function hyperv_unprivileged_run {
    <#
    .SYNOPSIS
    Run an executable in a VM as the configured unprivileged guest account.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [Parameter(Mandatory)]
        [string] $command,

        [AllowNull()]
        [string[]] $args = $null,

        [AllowNull()]
        [string] $cwd = $null,

        [ValidateRange(1, 2147483647)]
        [int] $timeout_ms = 60000
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    Assert-HyperVValue -Value $command -Name 'command'
    try {
        $credential = New-HyperVGuestCredential -Unprivileged
        $commandScript = New-HyperVCommandScript -Command $command -Args $args -Cwd $cwd
        $result = Invoke-HyperVGuestScriptInternal -VMName $vm_name -Script $commandScript -Credential $credential -TimeoutMs $timeout_ms
        ConvertTo-HyperVMcpJson -InputObject $result
    }
    catch {
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $false; error = $_.Exception.Message })
    }
}
