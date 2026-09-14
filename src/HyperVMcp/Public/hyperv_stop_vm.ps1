function hyperv_stop_vm {
    <#
    .SYNOPSIS
    Stop, save, or turn off a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [ValidateSet('shutdown', 'save', 'turnoff')]
        [string] $method = 'shutdown'
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    switch ($method) {
        'shutdown' { Stop-VM -Name $vm_name -Force -ErrorAction Stop }
        'save' { Stop-VM -Name $vm_name -Save -ErrorAction Stop }
        'turnoff' { Stop-VM -Name $vm_name -TurnOff -Force -ErrorAction Stop }
    }
    $state = [string] (Get-VM -Name $vm_name -ErrorAction Stop).State
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'stopped'
        vm_name = $vm_name
        method = $method
        state = $state
    })
}
