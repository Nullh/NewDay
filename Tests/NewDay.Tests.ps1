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
    Remove-Item -Force -Recurse ".\foo" -ErrorAction silentlycontinue
    Remove-Item -Force -Recurse ".\Entries" -ErrorAction silentlycontinue
    Remove-Item -Force -Recurse ".\Stats" -ErrorAction silentlycontinue

    It "Should create a file named yyyy-MM-dd.md in the current directory" {
        $path = Get-Location
        New-Day
        $date = Get-Date
        $date = $date.ToString("yyyy-MM-dd")
        "$($path.Path)\Entries\$date.md" | Should -Exist
    }

    Remove-Item -Force -Recurse ".\Entries" -ErrorAction silentlycontinue
    Remove-Item -Force -Recurse ".\Stats" -ErrorAction silentlycontinue

    It "Should create a Stats file in /Stats/yyyy-MM-dd.json" {
        $path = Get-Location
        New-Day
        $date = Get-Date
        $date = $date.ToString("yyyy-MM-dd")
        "$($path.Path)\Stats\$date.json" | Should -Exist
    }

    Remove-Item -Force -Recurse ".\Entries" -ErrorAction silentlycontinue
    Remove-Item -Force -Recurse ".\Stats" -ErrorAction silentlycontinue

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
    }

    Remove-Item -Force -Recurse ".\Entries" -ErrorAction silentlycontinue
    Remove-Item -Force -Recurse ".\Stats" -ErrorAction silentlycontinue
    New-Item -Path . -Name 'foo' -ItemType 'directory'

    It "Should create a file named yyyy-MM-dd.md in a specified directory" {
        New-Day -JournalPath "./foo"
        $date = Get-Date
        $date = $date.ToString("yyyy-MM-dd")
        $path = Get-Location
        $fullpath = "$($path.Path)\foo\Entries\$date.md"
        $fullpath | Should -Exist
    }

    Remove-Item -Force -Recurse ".\foo" -ErrorAction silentlycontinue
    New-Item -Path . -Name 'foo' -ItemType 'directory'

    It "Should set the file contents to match the format when no title specified" {
        $date = "2010-01-01"
        New-Day -Date $date -JournalPath "./foo"
        $path = Get-Location
        $fullPath = "$($path.Path)\foo\Entries\$date.md"
        $firstLine = ((Get-Content -Path $fullPath) -Split '\n')[0]
        $secondLine = ((Get-Content -Path $fullPath) -Split '\n')[1]
        $firstLine | Should -Be "# $(([datetime]$date).DayOfWeek) $(([datetime]$date).ToString('D'))"
        $secondLine | Should -Be "## $(([datetime]$date).DayOfWeek) $(([datetime]$date).ToString('yyyy-MM-dd'))"   
        $stats = Get-Content "$($path.Path)\foo\Stats\$date.json" | ConvertFrom-Json
        $stats.date | Should -Be $date
        $stats.mood | Should -Be $null
    }

    Remove-Item -Force -Recurse ".\foo" -ErrorAction silentlycontinue
    New-Item -Path . -Name 'foo' -ItemType 'directory'

    It "Should set the file contents to match the format when a title is specified" {
        $title = "This is a title"
        $date = "2010-01-01"
        New-Day -Title $title -Date $date -JournalPath ".\foo"
        $path = Get-Location
        $strCulture = (Get-Culture).TextInfo
        $title = $strCulture.ToTitleCase($title)
        $fullPath = "$($path.Path)\foo\Entries\$date-$($title.Replace(' ', '')).md"
        $firstLine = ((Get-Content -Path $fullPath) -Split '\n')[0]
        $secondLine = ((Get-Content -Path $fullPath) -Split '\n')[1]
        $firstLine | Should -Be "# $title"
        $secondLine | Should -Be "## $(([datetime]$date).DayOfWeek) $(([datetime]$date).ToString('yyyy-MM-dd'))"   
        $stats = Get-Content "$($path.Path)\foo\Stats\$date.json" | ConvertFrom-Json
        $stats.date | Should -Be $date
        $stats.mood | Should -Be $null
    }

    Remove-Item -Force -Recurse ".\foo" -ErrorAction silentlycontinue
    New-Item -Path . -Name 'foo' -ItemType 'directory'

    It "Should not create a new file if one already exists" {
        New-Day -Title "Test" -Date "2010-01-01" -JournalPath ".\foo"
        {New-Day -Date "2010-01-01" -JournalPath ".\foo"} | Should -Throw "Entry already exists for that day. Use New-DayEntry to add an additional entry."
    }
    Remove-Item -Force -Recurse ".\foo" -ErrorAction silentlycontinue
}

Describe "New-JournalEntry: Validation" {
    It "Should expose a function called New-JournalEntry" {
        $test = Get-Command -Module NewDay
        $test.Name | Should -Contain "New-JournalEntry"
    }
    It "Should accept a parameter Title" {
        (Get-Command New-JournalEntry).Parameters['Title'] | Should -Not -BeNullOrEmpty
    }
    It "Should accept a parameter Date" {
        (Get-Command New-JournalEntry).Parameters['Date'] | Should -Not -BeNullOrEmpty
    }
    It "Should accept a parameter Content" {
        (Get-Command New-JournalEntry).Parameters['Content'] | Should -Not -BeNullOrEmpty
    }
    It "Should accept a parameter JournalPath" {
        (Get-Command New-JournalEntry).Parameters['JournalPath'] | Should -Not -BeNullOrEmpty
    }
}

Describe "New-JournalEntry: Functional Tests" {
    Remove-Item -Force -Recurse ".\foo" -ErrorAction silentlycontinue
    New-Item -Path . -Name 'foo' -ItemType 'directory'

    It "Should add content to an exisiting journal file" {
        New-Day -Date "2010-01-01" -JournalPath ".\foo"
        New-JournalEntry -Content "Ate some toast!" -JournalPath ".\foo" -Date "2010-01-01"
        Get-Content ".\foo\Entries\2010-01-01.md" | Should -Contain "Ate some toast!"
    }

    Remove-Item -Force -Recurse ".\foo" -ErrorAction silentlycontinue
    New-Item -Path . -Name 'foo' -ItemType 'directory'

    It "Should add content to an exisiting journal file with title" {
        New-Day -Date "2010-01-01" -JournalPath ".\foo"
        New-JournalEntry -Content "Ate some toast!" -JournalPath ".\foo" -Date "2010-01-01" -Title "toast time!"
        Get-Content ".\foo\Entries\2010-01-01.md" | Should -Contain "Ate some toast!"
        Get-Content ".\foo\Entries\2010-01-01.md" | Should -Contain "## Toast Time!"
    }

    Remove-Item -Force -Recurse ".\foo" -ErrorAction silentlycontinue
    New-Item -Path . -Name 'foo' -ItemType 'directory'

    It "Should create a new entry file if one does not exist" {
        New-JournalEntry -Content "Ate some toast!" -JournalPath ".\foo" -Date "2010-01-01"
        Test-Path ".\foo\Entries\2010-01-01.md" | Should -Be $true
    }

    Remove-Item -Force -Recurse ".\foo" -ErrorAction silentlycontinue
}

Describe "Save-DailyStats: Validation" {
    It "Should expose a function called Save-DailyStats" {
        $test = Get-Command -Module NewDay
        $test.Name | Should -Contain "Save-DailyStats"
    }
    It "Should accept a parameter Date" {
        (Get-Command Save-DailyStats).Parameters['Date'] | Should -Not -BeNullOrEmpty
    }
    It "Should require parameter Mood" {
        (Get-Command Save-DailyStats).Parameters['Mood'].Attributes.Mandatory | Should -Be $true
    }
    It "Should require parameter BodyMood" {
        (Get-Command Save-DailyStats).Parameters['BodyMood'].Attributes.Mandatory | Should -Be $true
    }
    It "Should accept a parameter JournalPath" {
        (Get-Command Save-DailyStats).Parameters['JournalPath'] | Should -Not -BeNullOrEmpty
    }
}