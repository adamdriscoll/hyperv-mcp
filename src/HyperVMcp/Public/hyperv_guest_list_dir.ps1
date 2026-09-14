function hyperv_guest_list_dir {
    <#
    .SYNOPSIS
    List entries in a VM directory through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $vm_name,

        [Parameter(Mandatory)]
        [string] $remote_path,

        [AllowEmptyString()]
        [string] $username = '',

        [AllowEmptyString()]
        [string] $password = ''
    )

    try {
        Assert-HyperVValue -Value $vm_name -Name 'vm_name'
        Assert-HyperVValue -Value $remote_path -Name 'remote_path'
        $credential = New-HyperVGuestCredential -Username $username -Password $password
        $session = New-HyperVGuestSession -VMName $vm_name -Credential $credential -OperationTimeoutMs 60000
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
                } -ArgumentList $remote_path
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
