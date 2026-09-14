function Remove-HyperVVMCheckpoint {
    <#
    .SYNOPSIS
    Remove a checkpoint, optionally including all child checkpoints.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $CheckpointName,

        [bool] $IncludeSubtree = $false
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    Assert-HyperVValue -Value $CheckpointName -Name 'CheckpointName'
    $parameters = @{
        Name = $CheckpointName
        VMName = $VMName
        Confirm = $false
        ErrorAction = 'Stop'
    }
    if ($IncludeSubtree) {
        $parameters.IncludeAllChildSnapshots = $true
    }
    Remove-VMSnapshot @parameters
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'removed'
        vm_name = $VMName
        checkpoint_name = $CheckpointName
    })
}
