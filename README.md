# PSPagerDuty

This is a _just-enough-for-what-I-need-for-a-POC_ PagerDuty module, with minimal to no testing.  Use it at your own risk : )

If you want something more complete:

* Investigate AutoRest and the PagerDuty swagger definition
* Need more, or better tooling?  Look into tooling like [go-pagerduty](https://github.com/PagerDuty/go-pagerduty) or the [Terraform PagerDuty provider](https://www.terraform.io/docs/providers/pagerduty/index.html), among [other clients](https://v2.developer.pagerduty.com/docs/libraries)
* Looking for other PowerShell implementations?  Check out [PagerDuty-PowerShell-CmdLets](https://github.com/MattHodge/PagerDuty-PowerShell-CmdLets) or [PagerDuty-PoSh-API-Client](https://github.com/squid808/PagerDuty-PoSh-API-Client), although these appear to use older APIs

I will always consider issues and pull requests, but likely at a slow rate, and guided by whether I would use a thing.  Be sure to ping me in an issue before spending much time on something!

## Getting Started

```powershell
# One time setup
    # Download the repository
    # Unblock the zip
    # Extract the PSPagerDuty folder to a module path.  e.g.
    #   $env:USERPROFILE\Documents\WindowsPowerShell\Modules\
# Or, with PowerShell 5 or later or PowerShellGet:
    Install-Module PSPagerDuty

# Import the module.
    Import-Module PSPagerDuty    #Alternatively, Import-Module \\Path\To\PSPagerDuty

# Get commands in the module
    Get-Command -Module PSPagerDuty

# Get help
    Get-Help Get-PagerDutyData -Full

# Set token for the current session
    Set-PSPagerDuyConfiguration -Token $Token

# Set proxy for the current session
    Set-PSPagerDuyConfiguration -Proxy $Proxy
```
