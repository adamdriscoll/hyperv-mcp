function hyperv_checkpoint_list {
    <#
    .SYNOPSIS
    List all checkpoints for a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    $checkpoints = @(
        Get-VMSnapshot -VMName $vm_name -ErrorAction Stop | ForEach-Object {
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
