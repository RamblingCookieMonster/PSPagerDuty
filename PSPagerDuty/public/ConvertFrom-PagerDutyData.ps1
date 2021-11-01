function ConvertFrom-PagerDutyData
{
    <#
        .SYNOPSIS
            Parse output from PagerDuty API query
        .DESCRIPTION
            Parse output from PagerDuty API query

            For example, find date fields and convert from ISO 8601 strings to datetime objects
        .PARAMETER InputObject
            Incident to process
    #>
    [cmdletbinding()]
    param(
        [object[]]$InputObject
    )
    foreach ($Object in $InputObject)
    {
        $Properties = Get-PropertyOrder $Object
        foreach ($Prop in $Properties)
        {
            # Dates!
            if ($Prop -match '_at$' -and $Object.$Prop -match '^\d{4}-')
            {
                $Object.$Prop = Get-Date $Object.$Prop
            }
        }
        $Object
    }
}
