function hyperv_guest_read_file {
    <#
    .SYNOPSIS
    Read a bounded file from a VM and return its bytes as base64.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [Parameter(Mandatory)]
        [string] $remote_path,

        [ValidateRange(1, 2147483647)]
        [int] $max_bytes = 262144,

        [AllowEmptyString()]
        [string] $username = '',

        [AllowEmptyString()]
        [string] $password = ''
    )

    try {
        Assert-HyperVValue -Value $vm_name -Name 'vm_name'
        Assert-HyperVValue -Value $remote_path -Name 'remote_path'
        $credential = New-HyperVGuestCredential -Username $username -Password $password
        $session = New-HyperVGuestSession -VMName $vm_name -Credential $credential
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
            } -ArgumentList $remote_path, $max_bytes
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
