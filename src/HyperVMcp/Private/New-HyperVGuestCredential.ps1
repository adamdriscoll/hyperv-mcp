function New-HyperVGuestCredential {
    param(
        [AllowEmptyString()]
        [string] $Username = '',

        [AllowEmptyString()]
        [string] $Password = '',

        [switch] $Victim
    )

    if ($Victim) {
        $Username = $env:HYPERV_GUEST_VICTIM_USERNAME
        $Password = $env:HYPERV_GUEST_VICTIM_PASSWORD
        if ([string]::IsNullOrWhiteSpace($Username) -or [string]::IsNullOrWhiteSpace($Password)) {
            throw 'No victim credential configured. Set HYPERV_GUEST_VICTIM_USERNAME and HYPERV_GUEST_VICTIM_PASSWORD environment variables to an unprivileged guest account.'
        }
    }
    else {
        if ([string]::IsNullOrWhiteSpace($Username)) {
            $Username = $env:HYPERV_GUEST_USERNAME
        }
        if ([string]::IsNullOrWhiteSpace($Password)) {
            $Password = $env:HYPERV_GUEST_PASSWORD
        }
        if ([string]::IsNullOrWhiteSpace($Username) -or [string]::IsNullOrWhiteSpace($Password)) {
            throw 'Guest credentials are required. Supply username/password arguments or set HYPERV_GUEST_USERNAME and HYPERV_GUEST_PASSWORD environment variables.'
        }
    }

    $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    [System.Management.Automation.PSCredential]::new($Username, $securePassword)
}
