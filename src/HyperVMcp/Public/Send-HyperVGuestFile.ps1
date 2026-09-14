function Send-HyperVGuestFile {
    <#
    .SYNOPSIS
    Copy a host file into a VM through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $LocalPath,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [AllowEmptyString()]
        [string] $Username = '',

        [AllowEmptyString()]
        [string] $Password = ''
    )

    try {
        Assert-HyperVValue -Value $VMName -Name 'VMName'
        Assert-HyperVValue -Value $LocalPath -Name 'LocalPath'
        Assert-HyperVValue -Value $RemotePath -Name 'RemotePath'
        $credential = New-HyperVGuestCredential -Username $Username -Password $Password
        $session = New-HyperVGuestSession -VMName $VMName -Credential $credential -OperationTimeoutMs 300000
        try {
            $remoteDirectory = [System.IO.Path]::GetDirectoryName($RemotePath)
            if (-not [string]::IsNullOrWhiteSpace($remoteDirectory)) {
                Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock {
                    param($Directory)
                    New-Item -ItemType Directory -Path $Directory -Force | Out-Null
                } -ArgumentList $remoteDirectory
            }
            Copy-Item -ToSession $session -LiteralPath $LocalPath -Destination $RemotePath -Force -ErrorAction Stop
            $bytesCopied = (Get-Item -LiteralPath $LocalPath -ErrorAction Stop).Length
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
