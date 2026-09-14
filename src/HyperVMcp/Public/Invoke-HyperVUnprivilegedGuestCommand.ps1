function Invoke-HyperVUnprivilegedGuestCommand {
    <#
    .SYNOPSIS
    Run an executable in a VM as the configured unprivileged guest account.
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
        [int] $TimeoutMilliseconds = 60000
    )

    Assert-HyperVValue -Value $VMName -Name 'VMName'
    Assert-HyperVValue -Value $Command -Name 'Command'
    try {
        $credential = New-HyperVGuestCredential -Unprivileged
        $CommandScript = New-HyperVCommandScript -Command $Command -Args $ArgumentList -Cwd $WorkingDirectory
        $result = Invoke-HyperVGuestScriptInternal -VMName $VMName -Script $CommandScript -Credential $credential -TimeoutMs $TimeoutMilliseconds
        ConvertTo-HyperVMcpJson -InputObject $result
    }
    catch {
        ConvertTo-HyperVMcpJson -InputObject ([ordered]@{ ok = $false; error = $_.Exception.Message })
    }
}
