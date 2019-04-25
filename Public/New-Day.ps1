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
            Position = 2
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

    # Test if the folders already exists in the journal, and creates if necessary
    $entriesFolder = Test-Path -Path "$JournalPath\Entries"
    If(!$entriesFolder) {
        New-Item -Path $JournalPath -Name "Entries" -ItemType "directory"
    }
    $statsFolder = Test-Path -Path "$JournalPath\Stats"
    If(!$statsFolder) {
        New-Item -Path $JournalPath -Name "Stats" -ItemType "directory"
    }

    # Test if an entry already exists for the day requested
    $entry = Test-Path -Path "$JournalPath\Entries\$($Date.ToString("yyyy-MM-dd"))*.md"
    If($entry) {
        Throw "Entry already exists for that day. Use New-DayEntry to add an additional entry."
    }

    # Create the day's file
    If($Title) {
        $params = @{
            Path = "$JournalPath\Entries\$($Date.ToString("yyyy-MM-dd"))-$($Title.Replace(' ', '')).md"
            Value = "# $Title`n## $($Date.DayOfWeek) $($Date.ToString("yyyy-MM-dd"))"
        }
        Set-Content @params
    }
    Else {
        $params = @{
            Path = "$JournalPath\Entries\$($Date.ToString("yyyy-MM-dd")).md"
            Value = "# $($Date.DayOfWeek) $($Date.ToString('D'))`n## $($Date.DayOfWeek) $($Date.ToString("yyyy-MM-dd"))"
        }
        Set-Content @params
    }

    # Build the json for the stats file then create it
    $food = @()
    $food += [pscustomobject]@{
        meal = "snacks";
        items = @()
    }
    $stats = [pscustomobject]@{
        date = $Date.ToString("yyyy-MM-dd");
        mood = $null;
        bodymood = $null;
        food = $food;
    } 
    $json = $stats | ConvertTo-Json
    $params = @{
        Path = "$JournalPath\Stats\$($Date.ToString("yyyy-MM-dd")).json"
        Value = $json
    }
    Set-Content @params

    $entries = Get-ChildItem "$JournalPath\Entries\*.md"
    
    # Make the index file
    $params = @{
        Path = "$JournalPath\README.md"
        Value = @"
# Journal Entries`n 
 $(foreach($entry in $entries){Write-Output "* $($entry.Name)`n"})
"@
    }
    Set-Content @params
}