function hyperv_reset_vm {
    <#
    .SYNOPSIS
    Hard-reset a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    Stop-VM -Name $vm_name -TurnOff -Force -ErrorAction Stop
    Start-VM -Name $vm_name -ErrorAction Stop | Out-Null
    $state = [string] (Get-VM -Name $vm_name -ErrorAction Stop).State
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'reset'
        vm_name = $vm_name
        state = $state
    })
}
