function hyperv_configure_kdnet {
    <#
    .SYNOPSIS
    Configure KDNET kernel debugging in a VM through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [Parameter(Mandatory)]
        [string] $host_ip,

        [ValidateRange(1024, 65535)]
        [int] $port = 50000,

        [AllowEmptyString()]
        [string] $key = '',

        [bool] $reboot = $false,

        [AllowEmptyString()]
        [string] $username = '',

        [AllowEmptyString()]
        [string] $password = ''
    )

    Assert-HyperVValue -Value $vm_name -Name 'vm_name'
    Assert-HyperVValue -Value $host_ip -Name 'host_ip'
    if ([string]::IsNullOrWhiteSpace($key)) {
        $segments = 1..4 | ForEach-Object {
            [System.Security.Cryptography.RandomNumberGenerator]::GetInt32(0, 0x100000).ToString('x5')
        }
        $key = $segments -join '.'
    }

    $credential = New-HyperVGuestCredential -Username $username -Password $password
    $session = New-HyperVGuestSession -VMName $vm_name -Credential $credential -OperationTimeoutMs 60000
    try {
        $result = Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock {
            param($HostIp, $Port, $Key)
            $settings = & bcdedit.exe /dbgsettings net "hostip:$HostIp" "port:$Port" "key:$Key" 2>&1
            $enabled = & bcdedit.exe /debug on 2>&1
            [ordered]@{
                DbgSettings = "$settings"
                DebugOn = "$enabled"
                Current = (& bcdedit.exe /dbgsettings 2>&1 | Out-String)
            }
        } -ArgumentList $host_ip, $port, $key
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
        host_ip = $host_ip
        port = $port
        key = $key
        kernel_attach_string = "net:port=$port,key=$key"
        bcdedit_output = $result
        rebooting = $reboot
    })
}
