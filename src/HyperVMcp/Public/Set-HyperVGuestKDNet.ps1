function Set-HyperVGuestKDNet {
    <#
    .SYNOPSIS
    Configure KDNET kernel debugging in a VM through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $HostIP,

        [ValidateRange(1024, 65535)]
        [int] $Port = 50000,

        [AllowEmptyString()]
        [string] $Key = '',

        [bool] $Reboot = $false,

        [AllowEmptyString()]
        [string] $Username = '',

        [AllowEmptyString()]
        [string] $Password = ''
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    Assert-HyperVValue -Value $HostIP -Name 'HostIP'
    if ([string]::IsNullOrWhiteSpace($Key)) {
        $segments = 1..4 | ForEach-Object {
            [System.Security.Cryptography.RandomNumberGenerator]::GetInt32(0, 0x100000).ToString('x5')
        }
        $Key = $segments -join '.'
    }

    $credential = New-HyperVGuestCredential -Username $Username -Password $Password
    $session = New-HyperVGuestSession -VMName $VMName -Credential $credential -OperationTimeoutMs 60000
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
        } -ArgumentList $HostIP, $Port, $Key
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
        host_ip = $HostIP
        port = $Port
        key = $Key
        kernel_attach_string = "net:port=$Port,key=$Key"
        bcdedit_output = $result
        rebooting = $Reboot
    })
}
