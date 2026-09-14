function New-HyperVVMCheckpoint {
    <#
    .SYNOPSIS
    Create a checkpoint for a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [AllowEmptyString()]
        [string] $CheckpointName = ''
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    if ([string]::IsNullOrWhiteSpace($CheckpointName)) {
        $CheckpointName = "MCP-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    }
    Checkpoint-VM -Name $VMName -SnapshotName $CheckpointName -ErrorAction Stop | Out-Null
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'created'
        vm_name = $VMName
        checkpoint_name = $CheckpointName
    })
}
