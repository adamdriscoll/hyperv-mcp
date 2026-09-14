function hyperv_configure_kdcom {
    <#
    .SYNOPSIS
    Configure named-pipe serial kernel debugging for a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [AllowEmptyString()]
        [string] $pipe_name = '',

        [ValidateSet(1, 2)]
        [int] $com_port = 1,

        [bool] $reboot = $false,

        [AllowEmptyString()]
        [string] $username = '',

        [AllowEmptyString()]
        [string] $password = ''
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    if ([string]::IsNullOrWhiteSpace($pipe_name)) {
        $safeName = $vm_name.Replace(' ', '_').Replace('\', '_').Replace('/', '_')
        $pipe_name = "\\.\pipe\kd_$safeName"
    }

    $credential = New-HyperVGuestCredential -Username $username -Password $password
    Set-VMComPort -VMName $vm_name -Number $com_port -Path $pipe_name -ErrorAction Stop
    $session = New-HyperVGuestSession -VMName $vm_name -Credential $credential -OperationTimeoutMs 60000
    try {
        $result = Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock {
            param($ComPort)
            $settings = & bcdedit.exe /dbgsettings serial "debugport:$ComPort" baudrate:115200 2>&1
            $enabled = & bcdedit.exe /debug on 2>&1
            [ordered]@{
                DbgSettings = "$settings"
                DebugOn = "$enabled"
                Current = (& bcdedit.exe /dbgsettings 2>&1 | Out-String)
            }
        } -ArgumentList $com_port
    }
    finally {
        Remove-PSSession -Session $session -ErrorAction SilentlyContinue
    }

    if ($reboot) {
        Invoke-HyperVGuestReboot -VMName $vm_name -Credential $credential
    }
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'configured'
        vm_name = $vm_name
        com_port = $com_port
        pipe_path = $pipe_name
        kernel_attach_string = "com:pipe,port=$pipe_name,resets=0,reconnect"
        bcdedit_output = $result
        rebooting = $reboot
    })
}
