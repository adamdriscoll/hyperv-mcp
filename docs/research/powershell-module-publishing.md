# PowerShell module publishing practices

This repository follows these recommendations for building, testing, and
publishing `HyperVMcp`.

## Module layout and exports

A publishable module directory should use the module name and contain a
same-named manifest. The manifest's `RootModule` identifies the primary module
file relative to the manifest. The build therefore produces
`dist/HyperVMcp/HyperVMcp.psd1` and `HyperVMcp.psm1`.

`Public` and `Private` are source conventions rather than PowerShell visibility
rules. The root module loads both directories and defines the interface with
`Export-ModuleMember`; the manifest repeats an explicit `FunctionsToExport`
list. Explicit exports improve discovery and avoid the analysis cost and
accidental interface expansion of wildcard exports.

Sources:

- [About module manifests](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_module_manifests)
- [Installing a PowerShell module](https://learn.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module)
- [Export-ModuleMember](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/export-modulemember)
- [Module authoring considerations](https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/module-authoring-considerations)

## Versions and artifacts

PowerShell Gallery modules use a numeric `Major.Minor.Patch` `ModuleVersion`.
Prerelease labels belong in `PrivateData.PSData.Prerelease`; Gallery support is
more restrictive than complete SemVer 2 support. This repository intentionally
publishes only stable `vMajor.Minor.Patch` tags.

The build assembles and validates a clean module directory with
`Test-ModuleManifest`, then uses `Compress-PSResource` to create the package.
CI tests the expanded artifact and uploads the package. The release workflow
publishes that same `.nupkg`, avoiding a second, potentially different build.

Sources:

- [PowerShell Gallery publishing guidelines](https://learn.microsoft.com/en-us/powershell/gallery/concepts/publishing-guidelines)
- [Prerelease module versions](https://learn.microsoft.com/en-us/powershell/gallery/concepts/module-prerelease-support)
- [Creating and publishing an item](https://learn.microsoft.com/en-us/powershell/gallery/how-to/publishing-packages/publishing-a-package)
- [Compress-PSResource](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.psresourceget/compress-psresource)

## Tests and automation

Pester discovers `*.Tests.ps1` files. Setup that must run during test execution
belongs in `BeforeAll` or related setup blocks rather than loose discovery-time
code. CI runs Pester against the built manifest on `windows-latest`, where the
module's Windows-only PowerShell syntax and command metadata can be validated
without requiring a configured Hyper-V guest.

CI and publishing are separate workflows. Pull requests cannot access the
Gallery credential. Stable tags rebuild, rerun Pester, verify the tag format,
and publish through a protected GitHub Environment. Third-party actions are
pinned to immutable commit SHAs and `GITHUB_TOKEN` receives read-only contents
permission.

Sources:

- [Pester: Invoke-Pester](https://pester.dev/docs/commands/Invoke-Pester)
- [Pester: discovery and run](https://pester.dev/docs/usage/discovery-and-run)
- [Pester: test file structure](https://pester.dev/docs/usage/test-file-structure)
- [GitHub Actions workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [GitHub deployment environments](https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)
- [GitHub Actions secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use)

## Gallery authentication

`Publish-PSResource` is the current PSResourceGet command and can publish the
prebuilt `.nupkg` directly. PowerShell Gallery currently documents API-key
authentication; it does not document a completed OIDC or trusted-publishing
flow. The key is therefore stored as the `PSGALLERY_API_KEY` environment
secret and scoped only to the publishing step.

Sources:

- [Publish-PSResource](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.psresourceget/publish-psresource)
- [PowerShell Gallery account and API key](https://learn.microsoft.com/en-us/powershell/gallery/how-to/publishing-packages/publishing-a-package#powershell-gallery-account-and-api-key)
- [PowerShell Gallery trusted publishing request](https://github.com/PowerShell/PowerShellGallery/issues/353)
