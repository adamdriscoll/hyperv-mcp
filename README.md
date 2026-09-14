# HyperVMcp

`HyperVMcp` is a Windows-only PowerShell module that exposes 19 Hyper-V
management operations for MCP hosts such as
[`multi-pwsh`](https://github.com/Devolutions/multi-pwsh). It supports VM
lifecycle operations, checkpoints, KDNET and KDCOM setup, PowerShell Direct
guest execution, file transfer, and a separate unprivileged guest identity.

The commands return compact JSON so their result shapes remain stable when
they are exposed through a text-based MCP bridge. With `multi-pwsh`, command
names are prefixed with `powershell_`; for example, `hyperv_list_vms` is
advertised as `powershell_hyperv_list_vms`.

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
hyperv_list_vms
```

To host the commands with `multi-pwsh`, install a PowerShell runtime first.
From a clone of this repository, run the included launcher:

```powershell
multi-pwsh install 7.4
.\Start-HyperVMcpServer.ps1
```

## Credentials

Guest operations resolve credentials from explicit `username` and `password`
arguments first, then from these environment variables:

```text
HYPERV_GUEST_USERNAME
HYPERV_GUEST_PASSWORD
```

The `hyperv_victim_*` commands only use:

```text
HYPERV_GUEST_VICTIM_USERNAME
HYPERV_GUEST_VICTIM_PASSWORD
```

Set these variables in the MCP child-process environment or through a
user-scoped secret launcher. Do not commit credentials to MCP configuration.
Explicit credential arguments can be retained in model context, client logs,
or telemetry, so environment-based credential injection is preferred.

## Commands

| Command | Purpose |
|---|---|
| `hyperv_list_vms` | List VMs and current state |
| `hyperv_get_vm_info` | Get detailed VM configuration |
| `hyperv_start_vm` | Start a VM |
| `hyperv_stop_vm` | Gracefully stop, save, or turn off a VM |
| `hyperv_reset_vm` | Hard-reset a VM |
| `hyperv_checkpoint_create` | Create a checkpoint |
| `hyperv_checkpoint_list` | List checkpoints |
| `hyperv_checkpoint_restore` | Restore a checkpoint |
| `hyperv_checkpoint_remove` | Delete a checkpoint |
| `hyperv_configure_kdnet` | Configure KDNET in a guest |
| `hyperv_configure_kdcom` | Configure named-pipe serial debugging |
| `hyperv_guest_run` | Run a guest executable |
| `hyperv_guest_run_ps` | Run guest PowerShell |
| `hyperv_guest_put` | Copy a host file into a guest |
| `hyperv_guest_get` | Copy a guest file to the host |
| `hyperv_guest_read_file` | Read a bounded guest file as base64 |
| `hyperv_guest_list_dir` | List a guest directory |
| `hyperv_victim_run` | Run a guest executable as the victim identity |
| `hyperv_victim_run_ps` | Run guest PowerShell as the victim identity |

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
