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

    

}