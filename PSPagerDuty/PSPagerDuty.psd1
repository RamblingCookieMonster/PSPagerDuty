@{
    RootModule = 'PSPagerDuty.psm1'
    ModuleVersion = '0.0.1'
    GUID = 'a35dcabc-3568-4636-9716-5cb79f1b75b8'
    Author = 'Warren Frame'
    CompanyName = 'Unknown'
    Copyright = '(c) 2019 Warren Frame. All rights reserved.'
    Description = 'Simple PagerDuty PowerShell module'
    PowerShellVersion = '4.0'
    FunctionsToExport = @(
        'ConvertFrom-PagerDutyData',
        'Get-PagerDutyData',
        'Get-PagerDutyHeader',
        'Get-PagerDutyIncident',
        'Get-PSPagerDutyConfiguration',
        'Send-PagerDutyEvent',
        'Set-PSPagerDutyConfiguration'
    )

    PrivateData = @{
        PSData = @{
            Tags = @('pager', 'pagerduty', 'monitoring', 'alert')
            LicenseUri = 'https://github.com/RamblingCookieMonster/PSPagerDuty/blob/master/LICENSE'
            ProjectUri = 'https://github.com/RamblingCookieMonster/PSPagerDuty'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
