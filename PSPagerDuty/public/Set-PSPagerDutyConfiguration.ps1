function Set-PSPagerDutyConfiguration {
    <#
    .SYNOPSIS
       Set PSPagerDuty configuration values

    .DESCRIPTION
       Set PSPagerDuty configuration values

    .EXAMPLE
        Set-PSPagerDutyConfiguration -Token $Credential

        # Specify a default token to use for PSPagerDuty commands

    .FUNCTIONALITY
        PagerDuty
    #>
    [cmdletbinding()]
    param(
        [ValidateNotNull()]
        [string]$Token,
        [ValidateScript({if (([System.Uri]::IsWellFormedUriString($_, [System.UriKind]::Absolute)) -or ($_ -eq '')) {
            $true
        } else {
            throw "$_ is not a valid uri format."
        }})]
        [System.Uri]$Proxy
    )
    Switch ($PSBoundParameters.Keys)
    {
        'Token' { $Script:PSPagerDutyConfig.Token = $Token }
        'Proxy' { $Script:PSPagerDutyConfig.Proxy = $Proxy }
    }
}
