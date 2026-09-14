function Restart-HyperVVM {
    <#
    .SYNOPSIS
    Hard-reset a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    Stop-VM -Name $VMName -TurnOff -Force -ErrorAction Stop
    Start-VM -Name $VMName -ErrorAction Stop | Out-Null
    $state = [string] (Get-VM -Name $VMName -ErrorAction Stop).State
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'reset'
        vm_name = $VMName
        state = $state
    })
}
