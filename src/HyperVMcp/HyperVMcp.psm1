Set-StrictMode -Version 3.0

$privateFunctions = @(Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'Private') -Filter '*.ps1')
foreach ($function in $privateFunctions) {
    . $function.FullName
}

$publicFunctions = @(Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1')
foreach ($function in $publicFunctions) {
    . $function.FullName
}

Export-ModuleMember -Function $publicFunctions.BaseName
