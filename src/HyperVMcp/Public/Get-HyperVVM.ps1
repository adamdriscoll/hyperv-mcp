function Get-HyperVVM {
    <#
    .SYNOPSIS
    List all Hyper-V virtual machines and their current state.
    #>
    [CmdletBinding()]
    param()

    $vms = @(
        Get-VM -ErrorAction Stop | ForEach-Object {
            [ordered]@{
                name = $_.Name
                state = [string] $_.State
                status = $_.Status
                memory_mb = [Math]::Round($_.MemoryAssigned / 1MB, 1)
                cpu_count = $_.ProcessorCount
                uptime_seconds = $_.Uptime.TotalSeconds
            }
        }
    )
    ConvertTo-HyperVMcpJson -InputObject $vms
}
