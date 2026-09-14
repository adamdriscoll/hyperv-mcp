function Invoke-HyperVGuestScriptInternal {
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [string] $Script,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,

        [int] $TimeoutMs = 60000,

        [bool] $Elevated = $false
    )

    $operationTimeout = [Math]::Max(30000, $TimeoutMs + 10000)
    $session = New-HyperVGuestSession -VMName $VMName -Credential $Credential -OperationTimeoutMs $operationTimeout
    try {
        $encodedScript = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($Script))
        $result = Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock {
            param($EncodedScript, $RunElevated)

            $text = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($EncodedScript))
            if ($RunElevated) {
                $scriptPath = [System.IO.Path]::GetTempFileName() + '.ps1'
                $outputPath = [System.IO.Path]::GetTempFileName()
                try {
                    [System.IO.File]::WriteAllText($scriptPath, $text, [Text.Encoding]::Unicode)
                    $process = Start-Process powershell.exe `
                        -ArgumentList "-NonInteractive -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" *>`"$outputPath`"" `
                        -Verb RunAs -Wait -PassThru -ErrorAction Stop
                    [pscustomobject]@{
                        exit_code = $process.ExitCode
                        stdout = if (Test-Path -LiteralPath $outputPath) {
                            [System.IO.File]::ReadAllText($outputPath)
                        }
                        else {
                            ''
                        }
                        stderr = ''
                    }
                }
                finally {
                    Remove-Item -LiteralPath $scriptPath, $outputPath -Force -ErrorAction SilentlyContinue
                }
            }
            else {
                $global:LASTEXITCODE = $null
                $output = (& ([scriptblock]::Create($text)) 2>&1) | Out-String
                [pscustomobject]@{
                    exit_code = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
                    stdout = $output
                    stderr = ''
                }
            }
        } -ArgumentList $encodedScript, $Elevated

        [pscustomobject]@{
            ok = $true
            exit_code = $result.exit_code
            stdout = ([string] $result.stdout).Trim()
            stderr = [string] $result.stderr
        }
    }
    finally {
        Remove-PSSession -Session $session -ErrorAction SilentlyContinue
    }
}
