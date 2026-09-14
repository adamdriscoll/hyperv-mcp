@{
    RootModule = 'HyperVMcp.psm1'
    ModuleVersion = '0.1.0'
    GUID = '9f02a17f-96f0-459c-abcf-f9c9a3b47456'
    Author = 'Adam Driscoll'
    Description = 'PowerShell commands that expose Hyper-V management operations to MCP hosts such as multi-pwsh.'
    PowerShellVersion = '7.4'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'Get-HyperVVM'
        'Get-HyperVVMInfo'
        'Start-HyperVVM'
        'Stop-HyperVVM'
        'Restart-HyperVVM'
        'New-HyperVVMCheckpoint'
        'Get-HyperVVMCheckpoint'
        'Restore-HyperVVMCheckpoint'
        'Remove-HyperVVMCheckpoint'
        'Set-HyperVGuestKDNet'
        'Set-HyperVGuestKDCom'
        'Invoke-HyperVGuestCommand'
        'Invoke-HyperVGuestPowerShell'
        'Send-HyperVGuestFile'
        'Receive-HyperVGuestFile'
        'Get-HyperVGuestFileContent'
        'Get-HyperVGuestChildItem'
        'Invoke-HyperVUnprivilegedGuestCommand'
        'Invoke-HyperVUnprivilegedGuestPowerShell'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Hyper-V', 'MCP', 'multi-pwsh', 'Windows')
            ProjectUri = 'https://github.com/adamdriscoll/hyperv-mcp'
        }
    }
}
