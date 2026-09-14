function New-HyperVGuestSession {
    param(
        [Parameter(Mandatory)]
        [string] $VMName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,

        [int] $OperationTimeoutMs = 120000
    )

    $sessionOption = New-PSSessionOption -OperationTimeout $OperationTimeoutMs
    New-PSSession -VMName $VMName -Credential $Credential -SessionOption $sessionOption -ErrorAction Stop
}
