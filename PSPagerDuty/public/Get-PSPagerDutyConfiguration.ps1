function Get-PSPagerDutyConfiguration {
    <#
    .SYNOPSIS
       Get PSPagerDuty configuration values

    .DESCRIPTION
       Get PSPagerDuty configuration values

    .EXAMPLE
        Get-PSPagerDutyConfiguration

    .FUNCTIONALITY
        PagerDuty
    #>
    [cmdletbinding()]
    param()
    $Script:PSPagerDutyConfig
}