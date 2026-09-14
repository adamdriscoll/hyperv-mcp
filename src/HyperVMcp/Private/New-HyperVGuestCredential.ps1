function New-HyperVGuestCredential {
    param(
        [AllowEmptyString()]
        [string] $Username = '',

        [AllowEmptyString()]
        [string] $Password = '',

        [switch] $Unprivileged
    )

    if ($Unprivileged) {
        $Username = $env:HYPERV_GUEST_UNPRIVILEGED_USERNAME
        $Password = $env:HYPERV_GUEST_UNPRIVILEGED_PASSWORD
        if ([string]::IsNullOrWhiteSpace($Username) -or [string]::IsNullOrWhiteSpace($Password)) {
            throw 'No unprivileged guest credential configured. Set HYPERV_GUEST_UNPRIVILEGED_USERNAME and HYPERV_GUEST_UNPRIVILEGED_PASSWORD environment variables.'
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
