function Get-PagerDutyHeader {
    <#
        .SYNOPSIS
            Get PagerDuty header for v2 REST API
        .DESCRIPTION
            Get PagerDuty header for v2 REST API
        .PARAMETER Token
            Token to use for header
        .EXAMPLE
            $header = Get-PagerDutyHeader -Token $Token
    #>
        [cmdletbinding()]
        param (
            [ValidateNotNullOrEmpty()]
            [string]$Token = $Script:PSPagerDutyConfig.Token
        )
        @{
            "Accept" = "application/vnd.pagerduty+json;version=2"
            "Authorization" = "Token token=$Token"
        }
    }