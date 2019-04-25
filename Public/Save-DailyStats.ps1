<#
.SYNOPSIS
Save mood statistics for the day
.DESCRIPTION
Adds mood statistics to the stats file for the day
.EXAMPLE
PS C:\> Save-DailyStats -Mood 7 -BodyMood 5

Logs daily mood stats supplied
.PARAMETER Date
Defaults to current system date. The date which the journal day is for, in the format yyyy-MM-dd
.PARAMETER Mood
Overall mood for the day (0-9)
.PARAMETER BodyMood
How you feel abotu your body today (0-9)
.PARAMETER JournalPath
Defaults to current directory. The path to the journal folder
#>

Function Save-DailyStats {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [datetime]
        $Date = $(Get-Date),

        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [int]
        $Mood,

        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [int]
        $BodyMood,

        [Parameter(
            Mandatory = $false,
            Position = 3
        )]
        [string]
        $JournalPath
    )

    If($JournalPath) {
        $path = Test-Path -Path $JournalPath
        If(!$path) {
            Throw "JournalPath is not a valid folder"
        }
    }
    Else {
        $currentPath = Get-Location
        $JournalPath = $currentPath.Path
    }

    $stats = Get-Content "$JournalPath\Stats\$($Date.ToString("yyyy-MM-dd")).json" | ConvertFrom-Json
    $stats.mood = $Mood
    $stats.bodymood = $BodyMood

    $json = $stats | ConvertTo-Json
    $params = @{
        Path = "$JournalPath\Stats\$($Date.ToString("yyyy-MM-dd")).json"
        Value = $json
    }
    Set-Content @params
}