function hyperv_guest_get {
    <#
    .SYNOPSIS
    Copy a file from a VM to the host through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [Parameter(Mandatory)]
        [string] $remote_path,

        [Parameter(Mandatory)]
        [string] $local_path,

        [AllowEmptyString()]
        [string] $username = '',

        [AllowEmptyString()]
        [string] $password = ''
    )

    try {
        Assert-HyperVValue -Value $vm_name -Name 'vm_name'
        Assert-HyperVValue -Value $remote_path -Name 'remote_path'
        Assert-HyperVValue -Value $local_path -Name 'local_path'
        $credential = New-HyperVGuestCredential -Username $username -Password $password
        $session = New-HyperVGuestSession -VMName $vm_name -Credential $credential -OperationTimeoutMs 300000
        try {
            Copy-Item -FromSession $session -Path $remote_path -Destination $local_path -Force -ErrorAction Stop
            $bytesCopied = (Get-Item -LiteralPath $local_path -ErrorAction Stop).Length
        }
        finally {
            Remove-PSSession -Session $session -ErrorAction SilentlyContinue
        }
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $true; bytes_copied = $bytesCopied })
    }
    catch {
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $false; error = $_.Exception.Message })
    }
}
