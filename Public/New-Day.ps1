<#
.SYNOPSIS
Sets up the files for a new day in the journal
.DESCRIPTION
Creates a journal file and a stats file for the day specified
.EXAMPLE
PS C:\> New-Day

Creates a new journal file named yyyy-MM-dd.md in the root of the journal folder and a file called yyyy-MM-dd.json in the stats folder
.PARAMETER Title
The title of the entry
.PARAMETER Date
Defaults to current system date. The date which the journal day is for, in the format yyyy-MM-dd
.PARAMETER JournalPath
Defaults to current directory. The path to the journal folder
#>

Function New-Day {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [String]
        $Title,

        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [datetime]
        $Date = $(Get-Date),

        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string]
        $JournalPath
    )

    $strCulture = (Get-Culture).TextInfo
    $Title = $strCulture.ToTitleCase($Title)

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

    #Write-Output $Date.ToString("yyyy-MM-dd")
    If($Title) {
        $journalFilePath = "$($Date.ToString("yyyy-MM-dd"))-$($Title.Replace(' ', '')).md"
    }
    Else {
        $journalFilePath = "$($Date.ToString("yyyy-MM-dd")).md"
    }
    New-Item -Path $JournalPath -Name $journalFilePath -ItemType "file"


    Set-Content -Path "$JournalPath\$journalFilePath" -Value "# $($Date.DayOfWeek) $($Date.ToString('D'))`n## $($Date.DayOfWeek) $($Date.ToString("yyyy-MM-dd"))"
}