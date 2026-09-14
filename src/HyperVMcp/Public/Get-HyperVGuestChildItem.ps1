function Get-HyperVGuestChildItem {
    <#
    .SYNOPSIS
    List entries in a VM directory through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [AllowEmptyString()]
        [string] $Username = '',

        [AllowEmptyString()]
        [string] $Password = ''
    )

    try {
        Assert-HyperVValue -Value $VMName -Name 'VMName'
        Assert-HyperVValue -Value $RemotePath -Name 'RemotePath'
        $credential = New-HyperVGuestCredential -Username $Username -Password $Password
        $session = New-HyperVGuestSession -VMName $VMName -Credential $credential -OperationTimeoutMs 60000
        try {
            $entries = @(
                Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock {
                    param($Path)
                    Get-ChildItem -LiteralPath $Path -ErrorAction Stop | ForEach-Object {
                        [ordered]@{
                            name = $_.Name
                            is_dir = $_.PSIsContainer
                            size_bytes = if ($_.PSIsContainer) { 0 } else { $_.Length }
                            modified = $_.LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ')
                        }
                    }
                } -ArgumentList $RemotePath
            )
        }
        finally {
            Remove-PSSession -Session $session -ErrorAction SilentlyContinue
        }
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $true; entries = $entries })
    }
    catch {
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $false; error = $_.Exception.Message })
    }
}
