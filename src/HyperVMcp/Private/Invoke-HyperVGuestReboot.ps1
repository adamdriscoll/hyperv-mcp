function Invoke-HyperVGuestReboot {
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential
    )

    $session = New-HyperVGuestSession -VMName $VMName -Credential $Credential -OperationTimeoutMs 30000
    try {
        Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock {
            shutdown.exe /r /t 3
        } | Out-Null
    }
    finally {
        Remove-PSSession -Session $session -ErrorAction SilentlyContinue
    }
}
