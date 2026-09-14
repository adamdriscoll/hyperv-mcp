function Start-HyperVVM {
    <#
    .SYNOPSIS
    Start a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    Start-VM -Name $VMName -ErrorAction Stop | Out-Null
    $state = [string] (Get-VM -Name $VMName -ErrorAction Stop).State
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'started'
        vm_name = $VMName
        state = $state
    })
}
