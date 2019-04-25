<#
.SYNOPSIS
Adds a new journal entry for the day
.DESCRIPTION
Adds a new journal entry for the day specified
.EXAMPLE
PS C:\> New-JournalEntry -Content "Ate some good toast" -Title "Toast time!"

Creates a new journal entry for today with the provided title and content
.PARAMETER Title
The title of the entry
.PARAMETER Date
Defaults to current system date. The date which the journal day is for, in the format yyyy-MM-dd
.PARAMETER Content
The content of the journal entry
.PARAMETER JournalPath
Defaults to current directory. The path to the journal folder
#>

Function New-JournalEntry {
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
            Mandatory = $true,
            Position = 2
        )]
        [string]
        $Content,

        [Parameter(
            Mandatory = $false,
            Position = 3
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

    # Find the entry for the date supplied
    $entries = Get-ChildItem -Path "$JournalPath\Entries" -Filter "$($Date.ToString("yyyy-MM-dd"))*.md" -ErrorAction SilentlyContinue

    # If we don't have an entry for the date supplied, create a new journal entry for it
    If(!$entries -or $entries.count -eq 0) {
        New-Day -Title $Title -JournalPath $JournalPath -Date $Date
        $newFileCreated = $true
        $entries = Get-ChildItem -Path "$JournalPath\Entries" -Filter "$($Date.ToString("yyyy-MM-dd"))*.md" -ErrorAction SilentlyContinue
    }

    If($entries.count -gt 1) {
        Throw "Multiple journals found for this day! Please resolve before adding a new journal entry."
    }
    
    # Add the title if given
    If($Title -and !$newFileCreated) {
        Add-Content -Path "$JournalPath\Entries\$($entries[0].Name)" -Value "## $Title"
    }

    # Add the content to the entry
    Add-Content -Path "$JournalPath\Entries\$($entries[0].Name)" -Value "$Content"
     
}