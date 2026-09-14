function Invoke-HyperVGuestCommand {
    <#
    .SYNOPSIS
    Run an executable inside a VM through PowerShell Direct.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $Command,

        [AllowNull()]
        [string[]] $ArgumentList = $null,

        [AllowNull()]
        [string] $WorkingDirectory = $null,

        [ValidateRange(1, 2147483647)]
        [int] $TimeoutMilliseconds = 60000,

        [bool] $Elevated = $false,

        [AllowEmptyString()]
        [string] $Username = '',

        [AllowEmptyString()]
        [string] $Password = ''
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    Assert-HyperVValue -Value $Command -Name 'Command'
    try {
        $credential = New-HyperVGuestCredential -Username $Username -Password $Password
        $CommandScript = New-HyperVCommandScript -Command $Command -Args $ArgumentList -Cwd $WorkingDirectory
        $result = Invoke-HyperVGuestScriptInternal -VMName $VMName -Script $CommandScript -Credential $credential -TimeoutMs $TimeoutMilliseconds -Elevated $Elevated
        ConvertTo-HyperVMcpJson -InputObject $result
    }
    catch {
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $false; error = $_.Exception.Message })
    }
}
