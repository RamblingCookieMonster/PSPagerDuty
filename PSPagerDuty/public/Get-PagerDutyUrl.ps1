function Get-PagerDutyUrl
{
    <#
    .SYNOPSIS
       Get PSPagerDuty urls and content type

    .DESCRIPTION
       Get PSPagerDuty urls

    .EXAMPLE
        Get-PagerDutyUrl

    .FUNCTIONALITY
        PagerDuty
    #>

    [CmdletBinding()]
    [OutputType('System.Collections.Hashtable')]
    param(
    )

    begin
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        $HashUrl = @{
            Api    = @{
                url         = 'https://api.pagerduty.com'
                contenttype = 'application/json'
            }
            Events = @{
                url         = 'https://events.pagerduty.com/v2/enqueue'
                contenttype = 'application/json'
            }
        }
    }

    process
    {
    }

    end
    {
        return $HashUrl
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
