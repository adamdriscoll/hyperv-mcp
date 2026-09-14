function hyperv_checkpoint_restore {
    <#
    .SYNOPSIS
    Restore a Hyper-V virtual machine to a checkpoint, discarding subsequent state.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [Parameter(Mandatory)]
        [string] $checkpoint_name
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    Assert-HyperVValue -Value $checkpoint_name -Name 'checkpoint_name'
    Restore-VMSnapshot -Name $checkpoint_name -VMName $vm_name -Confirm:$false -ErrorAction Stop
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'restored'
        vm_name = $vm_name
        checkpoint_name = $checkpoint_name
    })
}
