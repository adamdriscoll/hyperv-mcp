function Get-HyperVVMCheckpoint {
    <#
    .SYNOPSIS
    List all checkpoints for a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    $checkpoints = @(
        Get-VMSnapshot -VMName $VMName -ErrorAction Stop | ForEach-Object {
            [ordered]@{
                name = $_.Name
                type = [string] $_.SnapshotType
                created = $_.CreationTime.ToString('o')
                parent_name = $_.ParentSnapshotName
            }
        }
    )
    ConvertTo-HyperVMcpJson -InputObject $checkpoints
}
