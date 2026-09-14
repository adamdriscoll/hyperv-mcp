function hyperv_start_vm {
    <#
    .SYNOPSIS
    Start a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    Start-VM -Name $vm_name -ErrorAction Stop | Out-Null
    $state = [string] (Get-VM -Name $vm_name -ErrorAction Stop).State
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'started'
        vm_name = $vm_name
        state = $state
    })
}
