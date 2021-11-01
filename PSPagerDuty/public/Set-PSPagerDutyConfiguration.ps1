function Set-PSPagerDutyConfiguration
{
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
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateNotNull()]
        [string]$Token
    )

    if ($PSCmdlet.ShouldProcess($Token))
    {

        Switch ($PSBoundParameters.Keys)
        {
            'Token' { $Script:PSPagerDutyConfig.Token = $Token }
        }
    }

}
