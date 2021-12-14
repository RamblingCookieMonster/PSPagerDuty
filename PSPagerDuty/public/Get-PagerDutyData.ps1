function Get-PagerDutyData {
<#
    .SYNOPSIS
        Get PagerDuty data from the v2 REST API
    .DESCRIPTION
        Get PagerDuty data from the v2 REST API
    .PARAMETER Type
        Type of object, or, what to append to the PagerDuty Uri

        For example:
            incidents
            services
            incidents/some_incident_id/log_entries
    .PARAMETER QueryHash
        Hashtable of filters for the PagerDuty API.

        For example this input:
            @{
                sortby = 'status'
                'include[]'= 'services',''services','first_trigger_log_entries''
            }

        Will append this to the Uri:
            sortby=status&include[]=services&include[]=first_trigger_log_entries
    .PARAMETER Limit
        Limit each query to this many results.
    .PARAMETER Offset
        Include this offset in the Uri.  Used for pagination.
    .PARAMETER Raw
        Return raw Invoke-RestMethod output
    .PARAMETER MaxQueries
        Limit pagination to this many API queries
    .PARAMETER Token
        PagerDuty API token
    .PARAMETER Proxy
        Uses a proxy server for the request, rather than connecting directly to the internet resource. Enter the Uniform Resource Identifier (URI) of a network proxy server

    .EXAMPLE
        Get-PagerDutyData -Type incidents -Limit 100 -Token $token
        # Get all PagerDuty incidents for token $token, 100 at a time
#>
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$True)]
        [string]$Type,
        [hashtable]$QueryHash = @{},

        [int]$Limit,
        [int]$Offset,
        [switch]$Raw,
        [int]$MaxQueries,
        [ValidateNotNullOrEmpty()]
        [string]$Token = $Script:PSPagerDutyConfig.Token,
        [ValidateScript({if ([System.Uri]::IsWellFormedUriString($_, [System.UriKind]::Absolute)) {
            $true
        } else {
            throw "$_ is not a valid uri format."
        }})]
        [System.Uri]$Proxy=$Script:PSPagerDutyConfig.Proxy
    )
    $Headers = @{
        "Accept" = "application/vnd.pagerduty+json;version=2"
        "Authorization" = "Token token=$Token"
    }
    $Append = $null
    $Type = $Type.ToLower()
    $BaseUri = "https://api.pagerduty.com/$Type"
    if($Limit -and -not $QueryHash.ContainsKey('limit')){
        $QueryHash.add('limit', $Limit)
    }
    if($Offset -and -not $QueryHash.ContainsKey('Offset')){
        $QueryHash.add('offset', $Offset)
    }

    $CallCount = 0
    do {
        [string[]]$UriParts = foreach($Key in $QueryHash.Keys){
            $Value = $QueryHash[$Key]
            if($Value -is [string[]]){
                foreach($item in $value){
                    "$Key=$Item"
                }
            }
            else {
                "$Key=$Value"
            }
        }
        if($UriParts.count -gt 0){
            $Append = Join-Parts -Separator '&' -Parts $UriParts
            $ThisUri = "$BaseUri`?$Append"
        }
        else{
            $ThisUri = $BaseUri
        }
        $Response = $null
        $RestMethodParams = @{ 
            Method  = 'Get';
            Uri     = $ThisUri;
            Headers = $Headers;
        }
        if ($Proxy) {
            $RestMethodParams.Add("Proxy", $Proxy)
        }
        $Response = Invoke-RestMethod @RestMethodParams
        $CallCount++
        if($Raw){
            $Response
        }
        else {
            ConvertFrom-PagerDutyData -InputObject $Response.$Type
        }
        if(-not $Response.more){
            break
        }
        if(-not $Limit){
            $Limit = $Response.limit
        }
        $CurrentOffset = $Response.offset + $Response.limit
        $QueryHash.offset = $CurrentOffset
        $QueryHash.limit = $Limit
    } while ($Response.more -and (-not $MaxQueries -or $CallCount -lt $MaxQueries))
}
