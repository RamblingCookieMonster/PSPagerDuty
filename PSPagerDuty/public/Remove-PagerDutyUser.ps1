function Remove-PagerDutyUser
{
    <#
    .SYNOPSIS
        Remove PagerDuty user from the v2 REST API
    .DESCRIPTION
        Remove PagerDuty user from the v2 REST API


    .PARAMETER UserID
        Id of the user to be deleted
    .PARAMETER Token
        PagerDuty API token
    .EXAMPLE
        Remove-PagerDutyUser -Token $token -UserID $UserID
        # Delete the user with the ID contained in the variable $UserID
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory = $True)]
        [string]$UserID,
        [ValidateNotNullOrEmpty()]
        [string]$Token = $Script:PSPagerDutyConfig.Token
    )

    $Headers = $null
    $Headers = Get-PagerDutyHeader -Token $Token
    if (-not $Headers)
    {
        Write-Error -Message ('Error during header generation')
        continue
    }

    $Urls = $null
    $Urls = Get-PagerDutyUrl
    if (-not $Urls)
    {
        Write-Error -Message ('Error durant la génération du header')
        continue
    }

    $BaseUri = $null
    $BaseUri = '{0}/users' -f $Urls.api.url
    $ContentType = $null
    $ContentType = $Urls.api.contenttype

    $RestMethod = @{
        Headers     = $Headers
        Uri         = '{0}/{1}' -f $BaseUri, $UserID
        Method      = 'Delete'
        ContentType = $ContentType
    }

    try
    {
        if ($PSCmdlet.ShouldProcess($UserID))
        {
            $LogEntry = $null
            $LogEntry = Invoke-WebRequest @RestMethod
            if ($LogEntry.StatusCode -eq 204)
            {
                Write-Verbose -Message ('User {0} deleted' -f $UserID)
            }
            else
            {
                Write-Error -Message ('Unable to delete the user {0}' -f $UserID)
            }
        }
    }
    catch
    {
        Write-Error -Message $_
    }
}
