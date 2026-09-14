function hyperv_guest_put {
    <#
    .SYNOPSIS
    Copy a host file into a VM through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [Parameter(Mandatory)]
        [string] $local_path,

        [Parameter(Mandatory)]
        [string] $remote_path,

        [AllowEmptyString()]
        [string] $username = '',

        [AllowEmptyString()]
        [string] $password = ''
    )

    try {
        Assert-HyperVValue -Value $vm_name -Name 'vm_name'
        Assert-HyperVValue -Value $local_path -Name 'local_path'
        Assert-HyperVValue -Value $remote_path -Name 'remote_path'
        $credential = New-HyperVGuestCredential -Username $username -Password $password
        $session = New-HyperVGuestSession -VMName $vm_name -Credential $credential -OperationTimeoutMs 300000
        try {
            $remoteDirectory = [System.IO.Path]::GetDirectoryName($remote_path)
            if (-not [string]::IsNullOrWhiteSpace($remoteDirectory)) {
                Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock {
                    param($Directory)
                    New-Item -ItemType Directory -Path $Directory -Force | Out-Null
                } -ArgumentList $remoteDirectory
            }
            Copy-Item -ToSession $session -LiteralPath $local_path -Destination $remote_path -Force -ErrorAction Stop
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
