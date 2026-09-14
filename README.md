# HyperVMcp

`HyperVMcp` is a Windows-only PowerShell module that exposes 19 Hyper-V
management operations for MCP hosts such as
[`multi-pwsh`](https://github.com/Devolutions/multi-pwsh). It supports VM
lifecycle operations, checkpoints, KDNET and KDCOM setup, PowerShell Direct
guest execution, file transfer, and a separate unprivileged guest identity.

The commands return compact JSON so their result shapes remain stable when
they are exposed through a text-based MCP bridge. With `multi-pwsh`, command
names are prefixed with `powershell_`; for example, `Get-HyperVVM` is
advertised as `powershell_get_hypervvm`.

## Requirements

- Windows 10/11 Pro or Enterprise, or Windows Server, with Hyper-V enabled.
- PowerShell 7.4 or later.
- The Hyper-V PowerShell module available to PowerShell 7.
- A host identity with the required Hyper-V permissions. Prefer membership in
  `Hyper-V Administrators` over elevating the entire MCP client.
- Windows guests with PowerShell Direct support for guest operations.

## Install

```powershell
Install-PSResource -Name HyperVMcp -Repository PSGallery
Import-Module HyperVMcp
Get-HyperVVM
```

Install `multi-pwsh` and a PowerShell runtime:

```powershell
irm https://github.com/Devolutions/multi-pwsh/releases/latest/download/install-multi-pwsh.ps1 | iex
multi-pwsh install 7.4
```

### Expose all module commands

The included launcher reads the exported command list from the installed
module manifest and starts a stdio MCP server:

```powershell
Install-PSResource -Name HyperVMcp -Repository PSGallery
.\Start-HyperVMcpServer.ps1
```

The selected PowerShell version must be able to discover the installed
`HyperVMcp` module. Choose another installed version when needed:

```powershell
.\Start-HyperVMcpServer.ps1 -PowerShellVersion 7.5
```

### Expose selected commands

Pass command names after `-McpCommands` to expose only those tools:

```powershell
multi-pwsh host 7.4 -mcp -McpCommands Get-HyperVVM Get-HyperVVMInfo Start-HyperVVM
```

`multi-pwsh` prefixes and normalizes the MCP tool names. The commands above
are advertised as `powershell_get_hypervvm`,
`powershell_get_hypervvminfo`, and `powershell_start_hypervvm`.

### Configure an MCP client

An MCP client can launch the included script as a stdio server. Replace the
script path with the absolute path to your clone:

```json
{
  "mcpServers": {
    "hyperv": {
      "command": "pwsh",
      "args": [
        "-NoLogo",
        "-NoProfile",
        "-File",
        "C:\\src\\hyperv-mcp\\Start-HyperVMcpServer.ps1",
        "-PowerShellVersion",
        "7.4"
      ]
    }
  }
}
```

Alternatively, configure `multi-pwsh` directly when only a small command
surface is needed:

```json
{
  "mcpServers": {
    "hyperv": {
      "command": "multi-pwsh",
      "args": [
        "host",
        "7.4",
        "-mcp",
        "-McpCommands",
        "Get-HyperVVM",
        "Get-HyperVVMInfo"
      ]
    }
  }
}
```

MCP mode exposes only the commands named after `-McpCommands`, uses stdio
transport, and runs tools with the privileges of the user that starts the
server.

## Credentials

Guest operations resolve credentials from explicit `Username` and `Password`
arguments first, then from these environment variables:

```text
HYPERV_GUEST_USERNAME
HYPERV_GUEST_PASSWORD
```

The `Invoke-HyperVUnprivilegedGuest*` commands only use:

```text
HYPERV_GUEST_UNPRIVILEGED_USERNAME
HYPERV_GUEST_UNPRIVILEGED_PASSWORD
```

Set these variables in the MCP child-process environment or through a
user-scoped secret launcher. Do not commit credentials to MCP configuration.
Explicit credential arguments can be retained in model context, client logs,
or telemetry, so environment-based credential injection is preferred.

## Commands

| Command | Purpose |
|---|---|
| `Get-HyperVVM` | List VMs and current state |
| `Get-HyperVVMInfo` | Get detailed VM configuration |
| `Start-HyperVVM` | Start a VM |
| `Stop-HyperVVM` | Gracefully stop, save, or turn off a VM |
| `Restart-HyperVVM` | Hard-reset a VM |
| `New-HyperVVMCheckpoint` | Create a checkpoint |
| `Get-HyperVVMCheckpoint` | List checkpoints |
| `Restore-HyperVVMCheckpoint` | Restore a checkpoint |
| `Remove-HyperVVMCheckpoint` | Delete a checkpoint |
| `Set-HyperVGuestKDNet` | Configure KDNET in a guest |
| `Set-HyperVGuestKDCom` | Configure named-pipe serial debugging |
| `Invoke-HyperVGuestCommand` | Run a guest executable |
| `Invoke-HyperVGuestPowerShell` | Run guest PowerShell |
| `Send-HyperVGuestFile` | Copy a host file into a guest |
| `Receive-HyperVGuestFile` | Copy a guest file to the host |
| `Get-HyperVGuestFileContent` | Read a bounded guest file as base64 |
| `Get-HyperVGuestChildItem` | List a guest directory |
| `Invoke-HyperVUnprivilegedGuestCommand` | Run a guest executable as the unprivileged guest identity |
| `Invoke-HyperVUnprivilegedGuestPowerShell` | Run guest PowerShell as the unprivileged guest identity |

## Build and test

The source module uses separate `Public` and `Private` function directories.
The build copies a publishable module to `dist\HyperVMcp`, sets its version,
validates its manifest, and creates a `.nupkg`:

```powershell
.\build.ps1 -Version 1.0.0
Invoke-Pester .\tests
```

Pull requests and pushes to `main` build the module and run Pester on
`windows-latest`. Stable tags publish the tested artifact to PowerShell
Gallery:

```powershell
git tag v1.0.0
git push origin v1.0.0
```

Publishing uses the `powershell-gallery` GitHub Environment and requires a
secret named `PSGALLERY_API_KEY`. Add required reviewers to that environment
if releases should require manual approval.

## Safety

This is a privileged local administration module. Its commands can hard power
off VMs, discard checkpoints, alter guest boot configuration, execute
arbitrary guest code, and copy files across the host/guest boundary.

- Connect it only to trusted local MCP clients.
- Use a dedicated Hyper-V host and disposable guests.
- Keep human approval enabled for destructive and arbitrary-execution tools.
- Use least-privilege host and guest identities.
- Treat checkpoint restore/removal and `turnoff`/reset as destructive.
- `elevated=true` uses `Start-Process -Verb RunAs` with
  `-ExecutionPolicy Bypass`, matching the reference behavior.
