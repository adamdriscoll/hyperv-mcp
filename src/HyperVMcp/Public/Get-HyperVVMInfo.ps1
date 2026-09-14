function Get-HyperVVMInfo {
    <#
    .SYNOPSIS
    Get detailed configuration and runtime information for a Hyper-V VM.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    $vm = Get-VM -Name $VMName -ErrorAction Stop
    $comPorts = @(Get-VMComPort -VMName $VMName -ErrorAction Stop | Select-Object Name, Path)
    $networkAdapters = @(
        Get-VMNetworkAdapter -VMName $VMName -ErrorAction Stop |
            Select-Object Name, SwitchName, MacAddress, IPAddresses
    )
    $hardDrives = @(
        Get-VMHardDiskDrive -VMName $VMName -ErrorAction Stop |
            Select-Object ControllerType, Path
    )
    $checkpointCount = @(Get-VMSnapshot -VMName $VMName -ErrorAction Stop).Count

    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        name = $vm.Name
        state = [string] $vm.State
        status = $vm.Status
        generation = $vm.Generation
        memory_mb = [Math]::Round($vm.MemoryAssigned / 1MB, 1)
        dynamic_memory = $vm.DynamicMemoryEnabled
        cpu_count = $vm.ProcessorCount
        uptime_seconds = $vm.Uptime.TotalSeconds
        checkpoint_count = $checkpointCount
        com_ports = $comPorts
        network_adapters = $networkAdapters
        hard_drives = $hardDrives
    })
}
