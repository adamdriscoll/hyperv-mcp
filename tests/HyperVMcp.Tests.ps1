BeforeAll {
    $expectedCommands = @(
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
    $modulePath = if ($env:HYPERV_MCP_MODULE_PATH) {
        $env:HYPERV_MCP_MODULE_PATH
    }
    else {
        Join-Path $PSScriptRoot '..\src\HyperVMcp\HyperVMcp.psd1'
    }
    $manifest = Test-ModuleManifest -Path $modulePath -ErrorAction Stop
    Import-Module $modulePath -Force -DisableNameChecking
}

AfterAll {
    Remove-Module HyperVMcp -Force -ErrorAction SilentlyContinue
}

Describe 'HyperVMcp module' {
    It 'has valid package metadata' {
        $manifest.Name | Should -Be 'HyperVMcp'
        $manifest.PowerShellVersion | Should -BeGreaterOrEqual ([version] '7.4')
        $manifest.ProjectUri | Should -Be 'https://github.com/adamdriscoll/hyperv-mcp'
    }

    It 'exports the complete MCP command surface and no helpers' {
        $actualCommands = @(
            Get-Command -Module HyperVMcp -CommandType Function |
                Select-Object -ExpandProperty Name
        )

        $actualCommands.Count | Should -Be 19
        $actualCommands | Sort-Object | Should -Be ($expectedCommands | Sort-Object)
    }

    It 'keeps reference defaults in command metadata' {
        (Get-Command Stop-HyperVVM).Parameters.Method.Attributes.ValidValues |
            Should -Be @('shutdown', 'save', 'turnoff')
        (Get-Command Set-HyperVGuestKDNet).Parameters.Port.Attributes.MinRange |
            Should -Be 1024
        (Get-Command Set-HyperVGuestKDNet).Parameters.Port.Attributes.MaxRange |
            Should -Be 65535
        (Get-Command Set-HyperVGuestKDCom).Parameters.COMPort.Attributes.ValidValues |
            Should -Be @(1, 2)
    }

    It 'requires the core reference parameters' {
        (Get-Command Get-HyperVVMInfo).Parameters.VMName.Attributes.Mandatory |
            Should -BeTrue
        (Get-Command Restore-HyperVVMCheckpoint).Parameters.CheckpointName.Attributes.Mandatory |
            Should -BeTrue
        (Get-Command Invoke-HyperVGuestCommand).Parameters.Command.Attributes.Mandatory |
            Should -BeTrue
        (Get-Command Invoke-HyperVGuestPowerShell).Parameters.Script.Attributes.Mandatory |
            Should -BeTrue
    }

    It 'returns a structured credential error without exposing a password' {
        $oldUsername = $env:HYPERV_GUEST_USERNAME
        $oldPassword = $env:HYPERV_GUEST_PASSWORD
        try {
            $env:HYPERV_GUEST_USERNAME = $null
            $env:HYPERV_GUEST_PASSWORD = $null
            $result = Invoke-HyperVGuestPowerShell -VMName test -Script 'Get-Date' | ConvertFrom-Json

            $result.ok | Should -BeFalse
            $result.error | Should -Match 'Guest credentials are required'
        }
        finally {
            $env:HYPERV_GUEST_USERNAME = $oldUsername
            $env:HYPERV_GUEST_PASSWORD = $oldPassword
        }
    }

    It 'uses dedicated environment variables for the unprivileged guest identity' {
        $oldUsername = $env:HYPERV_GUEST_UNPRIVILEGED_USERNAME
        $oldPassword = $env:HYPERV_GUEST_UNPRIVILEGED_PASSWORD
        try {
            $env:HYPERV_GUEST_UNPRIVILEGED_USERNAME = $null
            $env:HYPERV_GUEST_UNPRIVILEGED_PASSWORD = $null
            $result = Invoke-HyperVUnprivilegedGuestPowerShell -VMName test -Script 'Get-Date' | ConvertFrom-Json

            $result.ok | Should -BeFalse
            $result.error | Should -Match 'HYPERV_GUEST_UNPRIVILEGED_USERNAME'
            $result.error | Should -Not -Match 'password='
        }
        finally {
            $env:HYPERV_GUEST_UNPRIVILEGED_USERNAME = $oldUsername
            $env:HYPERV_GUEST_UNPRIVILEGED_PASSWORD = $oldPassword
        }
    }
}
