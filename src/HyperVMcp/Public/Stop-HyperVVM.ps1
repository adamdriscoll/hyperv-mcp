function Stop-HyperVVM {
    <#
    .SYNOPSIS
    Stop, save, or turn off a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [ValidateSet('shutdown', 'save', 'turnoff')]
        [string] $Method = 'shutdown'
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    switch ($Method) {
        'shutdown' { Stop-VM -Name $VMName -Force -ErrorAction Stop }
        'save' { Stop-VM -Name $VMName -Save -ErrorAction Stop }
        'turnoff' { Stop-VM -Name $VMName -TurnOff -Force -ErrorAction Stop }
    }
    $state = [string] (Get-VM -Name $VMName -ErrorAction Stop).State
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'stopped'
        vm_name = $VMName
        method = $Method
        state = $state
    })
}
