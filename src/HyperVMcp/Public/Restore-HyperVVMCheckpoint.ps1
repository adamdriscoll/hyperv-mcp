function Restore-HyperVVMCheckpoint {
    <#
    .SYNOPSIS
    Restore a Hyper-V virtual machine to a checkpoint, discarding subsequent state.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $CheckpointName
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    Assert-HyperVValue -Value $CheckpointName -Name 'CheckpointName'
    Restore-VMSnapshot -Name $CheckpointName -VMName $VMName -Confirm:$false -ErrorAction Stop
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'restored'
        vm_name = $VMName
        checkpoint_name = $CheckpointName
    })
}
