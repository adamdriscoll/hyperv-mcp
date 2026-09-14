function hyperv_checkpoint_create {
    <#
    .SYNOPSIS
    Create a checkpoint for a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [AllowEmptyString()]
        [string] $checkpoint_name = ''
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    if ([string]::IsNullOrWhiteSpace($checkpoint_name)) {
        $checkpoint_name = "MCP-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    }
    Checkpoint-VM -Name $vm_name -SnapshotName $checkpoint_name -ErrorAction Stop | Out-Null
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'created'
        vm_name = $vm_name
        checkpoint_name = $checkpoint_name
    })
}
