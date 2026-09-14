function Get-HyperVGuestFileContent {
    <#
    .SYNOPSIS
    Read a bounded file from a VM and return its bytes as base64.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [ValidateRange(1, 2147483647)]
        [int] $MaxBytes = 262144,

        [AllowEmptyString()]
        [string] $Username = '',

        [AllowEmptyString()]
        [string] $Password = ''
    )

    try {
        Assert-HyperVValue -Value $VMName -Name 'VMName'
        Assert-HyperVValue -Value $RemotePath -Name 'RemotePath'
        $credential = New-HyperVGuestCredential -Username $Username -Password $Password
        $session = New-HyperVGuestSession -VMName $VMName -Credential $credential
        try {
            $result = Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock {
                param($Path, $MaximumBytes)
                $bytes = [System.IO.File]::ReadAllBytes($Path)
                $truncated = $bytes.Length -gt $MaximumBytes
                if ($truncated) {
                    $bytes = $bytes[0..($MaximumBytes - 1)]
                }
                [ordered]@{
                    content_b64 = [Convert]::ToBase64String($bytes)
                    bytes_read = $bytes.Length
                    truncated = $truncated
                }
            } -ArgumentList $RemotePath, $MaxBytes
        }
        finally {
            Remove-PSSession -Session $session -ErrorAction SilentlyContinue
        }
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{
            ok = $true
            content_b64 = $result.content_b64
            bytes_read = $result.bytes_read
            truncated = $result.truncated
        })
    }
    catch {
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $false; error = $_.Exception.Message })
    }
}
