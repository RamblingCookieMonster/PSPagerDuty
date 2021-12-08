function Send-PagerDutyEvent {
<#
    .SYNOPSIS
        Send a PagerDuty event to the v2 Events API
    .DESCRIPTION
        Send a PagerDuty event to the v2 Events API

        See PagerDuty documentation for more information:
        https://v2.developer.pagerduty.com/docs/send-an-event-events-api-v2
    .PARAMETER IntegrationKey
        Service integration key to route this event to
    .PARAMETER DedupeKey
        Dedup_key to identify unique alerts
    .PARAMETER Summary
        Summary or title of the alert
    .PARAMETER Time
        Time for the alert.  Default: Now
    .PARAMETER Source
        Source for the alert.  Default: current computer name
    .PARAMETER Severity
        Severity of the alert.  Critical, Error, Warning, or Info
    .PARAMETER Component
        Component raising this alert
    .PARAMETER Group
        Affected grouping of components for this alert
    .PARAMETER Class
        Class / type of alert
    .PARAMETER Details
        Freeform details for this alert
    .PARAMETER Images
        List of images to include.

        Must be one or more hashtables with src, href, alt keys
        @{
            src='image url'
            href='link the image to some url'
            alt='alt text'
        }
    .PARAMETER Links
        List of links to include.

        Must be one or more hashtables with href, text keys
        @{
            href='some URL'
            text='description of URL'
        }
    .PARAMETER Action
        Action to take.  trigger, acknowledge, or resolve
    .PARAMETER Client
        Client generating this alert
    .PARAMETER ClientUrl
        Uri to client that generates this alert
    .PARAMETER Proxy
        Uses a proxy server for the request, rather than connecting directly to the internet resource. Enter the Uniform Resource Identifier (URI) of a network proxy server
    .EXAMPLE
        Send-PagerDutyEvent `
            -IntegrationKey REDACTED `
            -DedupeKey ad-privgroup-wframe-add-domainadmins-evildoer `
            -Summary 'wframe added evildoer to the privileged group domain admins' `
            -Source $ENV:COMPUTERNAME `
            -Severity critical `
            -Component 'Group' `
            -Group 'Security' `
            -Class 'Must-validate event' `
            -Details @{
                TargetUsername = 'evildoer'
                TargetGroup = 'Domain Admins'
                SubjectUsername = 'wframe'
            } `
            -Action trigger `
            -Client 'PowerShell-ad-privgroup' `
            -ClientUrl "https://some.useful.url"
            -Proxy "http://myproxy.com:3128"
#>
[cmdletbinding()]
param (
    [string]$IntegrationKey,
    [string]$DedupeKey,
    [string]$Summary,
    [datetime]$Time,
    [string]$Source,
    [validateset('critical', 'error', 'warning', 'info')]
    [string]$Severity,
    [string]$Component,
    [string]$Group,
    [string]$Class,
    [object]$Details,
    [hashtable[]]$Images, #src, href, alt
    [hashtable[]]$Links, #href, text
    [validateset('trigger', 'resolve', 'acknowledge')]
    [string]$Action,
    [string]$Client,
    [string]$ClientUrl,
    [ValidateScript({if ([System.Uri]::IsWellFormedUriString($_, [System.UriKind]::Absolute)) {
        $true
    } else {
        throw "$_ is not a valid uri format."
    }})]
    [System.Uri]$Proxy
)
$uri = 'https://events.pagerduty.com/v2/enqueue'

$Payload = @{
    payload = @{
        summary = $Summary
        source = $Source
        severity = $Severity
    }
    routing_key = $IntegrationKey
    dedup_key = $DedupeKey
    event_action = $Action
}

if($Time){
    $TimeStamp = Get-Date $Time -Format "o"
}
else {
    $TimeStamp = Get-Date -Format "o"
}
$Payload.payload.add('timestamp',$TimeStamp)

if($Details){
    $Payload.payload.add('custom_details',$Details)
}
if($Component){
    $Payload.payload.add('component',$Component)
}
if($Group){
    $Payload.payload.add('group',$Group)
}
if($Class){
    $Payload.payload.add('class',$Class)
}
if($Client){
    $Payload.add('client',$Client)
}
if($ClientUrl){
    $Payload.add('client_url',$ClientUrl)
}
if($Images.count -gt 0){
    $Payload.add('images',$Images)
}
if($Links.count -gt 0){
    $Payload.add('links',$Links)
}
$json = $Payload | ConvertTo-Json -Compress

$RestMethodParams = @{ 
    Method      = 'Post';
    Uri         = $Uri;
    Body        = $json;
    ContentType = 'application/json';
}
if ($Proxy) {
    $RestMethodParams.Add("Proxy", $Proxy)
}

Invoke-RestMethod @RestMethodParams
}
