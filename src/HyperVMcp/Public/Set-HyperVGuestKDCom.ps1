function Set-HyperVGuestKDCom {
    <#
    .SYNOPSIS
    Configure named-pipe serial kernel debugging for a Hyper-V virtual machine.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [AllowEmptyString()]
        [string] $PipeName = '',

        [ValidateSet(1, 2)]
        [int] $COMPort = 1,

        [bool] $Reboot = $false,

        [AllowEmptyString()]
        [string] $Username = '',

        [AllowEmptyString()]
        [string] $Password = ''
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    if ([string]::IsNullOrWhiteSpace($PipeName)) {
        $safeName = $VMName.Replace(' ', '_').Replace('\', '_').Replace('/', '_')
        $PipeName = "\\.\pipe\kd_$safeName"
    }

    $credential = New-HyperVGuestCredential -Username $Username -Password $Password
    Set-VMComPort -VMName $VMName -Number $COMPort -Path $PipeName -ErrorAction Stop
    $session = New-HyperVGuestSession -VMName $VMName -Credential $credential -OperationTimeoutMs 60000
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
        } -ArgumentList $COMPort
    }
    finally {
        Remove-PSSession -Session $session -ErrorAction SilentlyContinue
    }

    if ($Reboot) {
        Invoke-HyperVGuestReboot -VMName $VMName -Credential $credential
    }
    ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
        status = 'configured'
        vm_name = $VMName
        com_port = $COMPort
        pipe_path = $PipeName
        kernel_attach_string = "com:pipe,port=$PipeName,resets=0,reconnect"
        bcdedit_output = $result
        rebooting = $Reboot
    })
}
