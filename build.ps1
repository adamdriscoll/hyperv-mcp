[CmdletBinding()]
param(
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string] $Version = '0.1.0',

    [string] $OutputPath = (Join-Path $PSScriptRoot 'dist')
)

$ErrorActionPreference = 'Stop'
$sourcePath = Join-Path $PSScriptRoot 'src\HyperVMcp'
$modulePath = Join-Path $OutputPath 'HyperVMcp'

if (Test-Path -LiteralPath $modulePath) {
    Remove-Item -LiteralPath $modulePath -Recurse -Force
}

New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
Copy-Item -LiteralPath $sourcePath -Destination $modulePath -Recurse

$manifestPath = Join-Path $modulePath 'HyperVMcp.psd1'
Update-ModuleManifest -Path $manifestPath -ModuleVersion $Version
[void] (Test-ModuleManifest -Path $manifestPath -ErrorAction Stop)

$packagePath = Join-Path $OutputPath "HyperVMcp.$Version.nupkg"
if (Test-Path -LiteralPath $packagePath) {
    Remove-Item -LiteralPath $packagePath -Force
}

Compress-PSResource -Path $modulePath -DestinationPath $OutputPath | Out-Null
Get-Item -LiteralPath $modulePath, $packagePath
