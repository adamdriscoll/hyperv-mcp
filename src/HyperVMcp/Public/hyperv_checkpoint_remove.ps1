function hyperv_checkpoint_remove {
    <#
    .SYNOPSIS
    Remove a checkpoint, optionally including all child checkpoints.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [Parameter(Mandatory)]
        [string] $checkpoint_name,

        [bool] $include_subtree = $false
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    Assert-HyperVValue -Value $checkpoint_name -Name 'checkpoint_name'
    $parameters = @{
        Name = $checkpoint_name
        VMName = $vm_name
        Confirm = $false
        ErrorAction = 'Stop'
    }
    if ($include_subtree) {
        $parameters.IncludeAllChildSnapshots = $true
    }
    Remove-VMSnapshot @parameters
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'removed'
        vm_name = $vm_name
        checkpoint_name = $checkpoint_name
    })
}
