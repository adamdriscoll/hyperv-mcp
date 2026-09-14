[CmdletBinding()]
param(
    [string] $PowerShellVersion = '7.4'
)

$ErrorActionPreference = 'Stop'
$module = Get-Module -ListAvailable -Name HyperVMcp |
    Sort-Object Version -Descending |
    Select-Object -First 1

if ($null -eq $module) {
    throw 'HyperVMcp is not installed. Run Install-PSResource HyperVMcp first.'
}

$commands = (Import-PowerShellDataFile -Path $module.Path).FunctionsToExport
& multi-pwsh host $PowerShellVersion -mcp -McpCommands $commands
exit $LASTEXITCODE
