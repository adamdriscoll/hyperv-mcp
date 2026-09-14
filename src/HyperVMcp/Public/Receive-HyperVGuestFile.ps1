function Receive-HyperVGuestFile {
    <#
    .SYNOPSIS
    Copy a file from a VM to the host through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [Parameter(Mandatory)]
        [string] $LocalPath,

        [AllowEmptyString()]
        [string] $Username = '',

        [AllowEmptyString()]
        [string] $Password = ''
    )

    try {
        Assert-HyperVValue -Value $VMName -Name 'VMName'
        Assert-HyperVValue -Value $RemotePath -Name 'RemotePath'
        Assert-HyperVValue -Value $LocalPath -Name 'LocalPath'
        $credential = New-HyperVGuestCredential -Username $Username -Password $Password
        $session = New-HyperVGuestSession -VMName $VMName -Credential $credential -OperationTimeoutMs 300000
        try {
            Copy-Item -FromSession $session -Path $RemotePath -Destination $LocalPath -Force -ErrorAction Stop
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
