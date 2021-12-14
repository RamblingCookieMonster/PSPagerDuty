function Get-PagerDutyIncident {
<#
    .SYNOPSIS
        Get PagerDuty data from the v2 REST API
    .DESCRIPTION
        Get PagerDuty data from the v2 REST API
    .PARAMETER QueryHash
        Hashtable of filters for the PagerDuty API.

        For example this input:
            @{
                sortby = 'status'
                'include[]'= 'services',''services','first_trigger_log_entries''
            }

        Will append this to the Uri:
            sortby=status&include[]=services&include[]=first_trigger_log_entries

    .PARAMETER Since
        Get incidents since this date
    .PARAMETER Until
        Get incidents until this date
    .PARAMETER Status
        Get incidents with these status(es)
    .PARAMETER DedupeKey
        Get incidents with these incident_keys

        Note that events created by Events v2 API do _not_ have a dedup_key in their definition
        Use -CustomDetails to include this property
    .PARAMETER ServiceIDs
        Filter for incidents with these service IDs
    .PARAMETER TeamIDs
        Filter for incidents with these team IDs
    .PARAMETER UserIDs
        Filter for incidents with these User IDs
    .PARAMETER Urgency
        Filter for incidents with these urgencies
    .PARAMETER TimeZone
        Specify Timezone for returned dates to be rendered
    .PARAMETER SortBy
        Sort returned incidents by this property
    .PARAMETER Include
        Include other related data.  Accepts:
          users
          services
          first_trigger_log_entries
          escalation_policies
          teams
          assignees
          acknowledgers
          priorities
          conference_bridge
    .PARAMETER CustomDetails
        If specified, query each returned incident's first_trigger_log_entry Uri

        We add these properties to the incident itself:
            incident_key
            details
            client
            client_url
    .PARAMETER Limit
        Limit each query to this many results.
    .PARAMETER Raw
        Return raw Invoke-RestMethod output
    .PARAMETER MaxQueries
        Limit pagination to this many API queries
    .PARAMETER Token
        PagerDuty API token
    .PARAMETER Proxy
        Uses a proxy server for the request, rather than connecting directly to the internet resource. Enter the Uniform Resource Identifier (URI) of a network proxy server
    .EXAMPLE
        Get-PagerDutyIncident -Token $token -Status acknowledged, resolved
        # Get resolved and acknowledged incidents for token $token, 100 at a time.
    .EXAMPLE
        Get-PagerDutyIncident -Token $token -Since (Get-Date).AddDays(-1) -CustomDetails
        # Get incidents from the last day, including custom details
#>
    [cmdletbinding()]
    param(
        [hashtable]$QueryHash = @{},
        [datetime]$Since,
        [datetime]$Until,
        [validateset('triggered','acknowledged','resolved')]
        [string[]]$Status, #statuses
        [string]$DedupeKey, #incident_key
        [string[]]$ServiceIDs, #service_ids
        [string[]]$TeamIDs, # team_ids
        [string[]]$UserIDs, # user_ids
        [string[]]$Urgency, # urgencies
        [string]$TimeZone, # time_zone
        [string]$SortBy, # sort_by
        [validateset('users','services','first_trigger_log_entries', 'escalation_policies', 'teams', 'assignees', 'acknowledgers', 'priorities', 'conference_bridge')]
        [string[]]$Include,
        [switch]$CustomDetails,

        [int]$Limit = 100,
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
    $Params = @{}
    switch($PSBoundParameters.Keys) {
        'Since' {
            $QueryHash.since = $Since.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
            if(-not $PSBoundParameters.ContainsKey('Until')){
                $QueryHash.until = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
            }    
        }
        'Until' {$QueryHash.until = $Until.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')}
        'Status' {$QueryHash.'statuses[]' = $Status} #statuses
        'DedupeKey' {$QueryHash.incident_key = $DedupeKey}  #incident_key
        'ServiceIDs' {$QueryHash.'service_ids[]' = $ServiceIDs} #service_ids
        'TeamIDs' {$QueryHash.'team_ids[]' = $TeamIDs} # team_ids
        'UserIDs' {$QueryHash.'user_ids[]' = $UserIDs} # user_ids
        'Urgency' {$QueryHash.'urgencies[]' = $Urgency} # urgencies
        'TimeZone' {$QueryHash.time_zone = $TimeZone} # time_zone
        'SortBy' {$QueryHash.sort_by = $SortBy} # sort_by
        'Include' {$QueryHash.'include[]' = $Include}
        'MaxQueries' {$Params.add('MaxQueries', $MaxQueries)}
        'Limit' {$Params.add('Limit', $Limit)}
        'Token' {$Params.add('Token', $Token)}
        'Raw' {$Params.add('Raw', $Raw)}
    }
    if ($Proxy) {
        $Params.Add("Proxy", $Proxy)
    }
    $Output = @( Get-PagerDutyData @Params -Type incidents -QueryHash $QueryHash -Verbose:$VerbosePreference )
    if($CustomDetails){
        $Header = Get-PagerDutyHeader -Token $Token
        foreach($Incident in $Output){
            $Uri = '{0}?include[]=channels' -f $Incident.first_trigger_log_entry.self
            $LogEntry = $null
            $RestMethodParams = @{
                Uri     = $Uri;
                Headers = $Header;
                Verbose = $VerbosePreference;
            }
            if ($Proxy) {
                $RestMethodParams.Add("Proxy", $Proxy)
            }
            $LogEntry = Invoke-RestMethod @RestMethodParams
            if($LogEntry.log_entry.channel.client_url){
                Add-Member -InputObject $Incident -MemberType NoteProperty -Name client_url -Value $LogEntry.log_entry.channel.client_url -Force
            }
            if($LogEntry.log_entry.channel.client){
                Add-Member -InputObject $Incident -MemberType NoteProperty -Name client -Value $LogEntry.log_entry.channel.client -Force
            }
            if($LogEntry.log_entry.channel.details){
                Add-Member -InputObject $Incident -MemberType NoteProperty -Name details -Value $LogEntry.log_entry.channel.details -Force
            }
            if($LogEntry.log_entry.channel.incident_key){
                Add-Member -InputObject $Incident -MemberType NoteProperty -Name incident_key -Value $LogEntry.log_entry.channel.incident_key -Force
            }
            if($LogEntry.log_entry.channel.cef_details.dedup_key){
                Add-Member -InputObject $Incident -MemberType NoteProperty -Name dedup_key -Value $LogEntry.log_entry.channel.cef_details.dedup_key -Force
            }
            Add-Member -InputObject $Incident -MemberType NoteProperty -Name first_trigger_log_entry_raw -Value $LogEntry -Force
        }
    }
    $Output
}
