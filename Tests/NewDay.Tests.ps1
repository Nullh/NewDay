$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'

$module = Get-Module NewDay
if ($null -ne $module) {
    Write-Host "Removing module"
    Remove-Module NewDay
}
Write-Host "Importing module $here\..\$sut"
Import-Module $here\..\$sut

Describe "New-Day: Validation" {
    It "Should expose a function called New-Day" {
        $test = Get-Command -Module NewDay
        $test.Name | Should -Contain "New-Day"
    }
    It "Should accept a parameter Title" {
        (Get-Command New-Day).Parameters['Title'] | Should -Not -BeNullOrEmpty
    }
    It "Should accept a parameter Date" {
        (Get-Command New-Day).Parameters['Date'] | Should -Not -BeNullOrEmpty
    }
    It "Should accept a parameter JournalPath" {
        (Get-Command New-Day).Parameters['JournalPath'] | Should -Not -BeNullOrEmpty
    }
    It "Should throw if not given a valid Date" {
        {New-Day -Date "This is not a date"} | Should -Throw
    }
    It "Should throw if not given a valid JournalPath" {
        {New-Day -JournalPath "This is not a path"} | Should -Throw "JournalPath is not a valid folder"
    }
    #It "Should return the current date given no parameters" {
    #    $test = New-Day
    #    $today = Get-Date
    #    $test | Should -Be $today.ToString("yyyy-MM-dd")
    #}
    #It "Should return the specified date if provided" {
    #    $test = New-Day -Date "2010-05-22"
    #    $test | Should -Be "2010-05-22"
    #}
}
Describe "New-Day: File Creation" {
    It "Should create a file named yyyy-MM-dd.md in the current directory" {
        New-Day
        $date = Get-Date
        $date = $date.ToString("yyyy-MM-dd")
        $path = Get-Location
        "$($path.Path)\Entries\$date.md" | Should -Exist
        Remove-Item -Path "$($path.Path)\Entries\$date.md"
    }
    It "Should create a file named yyyy-MM-dd-ThisIsATitle.md in the current directory" {
        $title = "This is a title"
        New-Day -Title $title
        $date = Get-Date
        $date = $date.ToString("yyyy-MM-dd")
        $path = Get-Location
        $strCulture = (Get-Culture).TextInfo
        $title = $strCulture.ToTitleCase($title)
        $fullpath = "$($path.Path)\Entries\$date-$($title.Replace(' ', '')).md"
        $fullpath | Should -Exist
        Remove-Item -Recurse -Force -Path ".\Entries"
    }
    It "Should create a file named yyyy-MM-dd.md in a specified directory" {
        New-Item -Path . -Name 'foo' -ItemType 'directory'
        New-Day -JournalPath "./foo"
        $date = Get-Date
        $date = $date.ToString("yyyy-MM-dd")
        $path = Get-Location
        $fullpath = "$($path.Path)\foo\Entries\$date.md"
        $fullpath | Should -Exist
        Remove-Item -Recurse -Force -Path ".\foo" 
    }
    It "Should set the file contents to match the format when no title specified" {
        $date = "2010-01-01"
        New-Item -Path . -Name 'foo' -ItemType 'directory'
        New-Day -Date $date -JournalPath "./foo"
        $path = Get-Location
        $fullPath = "$($path.Path)\foo\Entries\$date.md"
        $firstLine = ((Get-Content -Path $fullPath) -Split '\n')[0]
        $secondLine = ((Get-Content -Path $fullPath) -Split '\n')[1]
        Remove-Item -Recurse -Force -Path ".\foo" 
        $firstLine | Should -Be "# $(([datetime]$date).DayOfWeek) $(([datetime]$date).ToString('D'))"
        $secondLine | Should -Be "## $(([datetime]$date).DayOfWeek) $(([datetime]$date).ToString('yyyy-MM-dd'))"   
    }
    It "Should set the file contents to match the format when a title is specified" {
        $title = "This is a title"
        $date = "2010-01-01"
        New-Item -Path . -Name 'foo' -ItemType 'directory'
        New-Day -Title $title -Date $date -JournalPath "./foo"
        $path = Get-Location
        $strCulture = (Get-Culture).TextInfo
        $title = $strCulture.ToTitleCase($title)
        $fullPath = "$($path.Path)\foo\Entries\$date-$($title.Replace(' ', '')).md"
        $firstLine = ((Get-Content -Path $fullPath) -Split '\n')[0]
        $secondLine = ((Get-Content -Path $fullPath) -Split '\n')[1]
        Remove-Item -Recurse -Force -Path ".\foo" 
        $firstLine | Should -Be "# $title"
        $secondLine | Should -Be "## $(([datetime]$date).DayOfWeek) $(([datetime]$date).ToString('yyyy-MM-dd'))"   
    }
}