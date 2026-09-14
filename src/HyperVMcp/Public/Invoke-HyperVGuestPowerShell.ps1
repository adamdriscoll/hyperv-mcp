function Invoke-HyperVGuestPowerShell {
    <#
    .SYNOPSIS
    Run a PowerShell script inside a VM through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $Script,

        [ValidateRange(1, 2147483647)]
        [int] $TimeoutMilliseconds = 60000,

        [bool] $Elevated = $false,

        [AllowEmptyString()]
        [string] $Username = '',

        [AllowEmptyString()]
        [string] $Password = ''
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    Assert-HyperVValue -Value $Script -Name 'script'
    try {
        $credential = New-HyperVGuestCredential -Username $Username -Password $Password
        $result = Invoke-HyperVGuestScriptInternal -VMName $VMName -Script $Script -Credential $credential -TimeoutMs $TimeoutMilliseconds -Elevated $Elevated
        ConvertTo-HyperVMcpJson -InputObject $result
    }
    catch {
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $false; error = $_.Exception.Message })
    }
}
