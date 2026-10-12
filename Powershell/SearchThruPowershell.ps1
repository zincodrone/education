#Introduction:
#I've seperated this code into three distinct sections, each section does a different thing as part of the script.
#This is purely to increase readability and allow for easier editing.
#I've worked on the script for about 3 days on and off over the Fall Break, so much documentation research was required.
#You'll find dates for when each part was created.
#And as always since it's required explaining the code.
#You can't imagine the amount of useless quirks that powerhsell scripting has.
#I mean they kinda make sense but for a script this simple they are pretty unncessary.
#You'll see comments inside function that explain specific things with explanations about what the specific section of code actually does.

#Info:
#I started coding this in Notepad++ and then I starting using VSCode.
#The reasoning is because I could test the script inside VSCode and not have to constantly run it in cmd, VSCode is way more intuitve, and I have more experince using it with a ton of my own personal settings.
#Yes I didn't use a VM, oh the horror, but writing and testing this script in a VM is pretty pointless since I know it's not overwriting data, and besides I'm testing it inside VSCode anyway.
#I've worked on the script for 20 hours at this point over multiple days, not sure what else to put.

#TODO:
#Reformat Script
#Fix .dll showing up in search.
    #I'm actually unsure how to fix this, maybe an exclusion could work, or a whitelist?

#END OF INTRODUCTION AND INFO





#What this is:
# Default

#Explanation:
#These are the default values for the variables.
#They are used as the default when the script is ran.

#Creation Date:
#10/8/2026

#Last Modified
#10/8/2026

#Default will show at the start of running the script, each of these variables you can see in the Menu function.
$rootset = "C:\"
#Default array for keywords. 
$keywords = @()
#Join-Path combines USERPROFILE and Desktop\results.txt for a path for the output file.
$out = Join-Path $env:USERPROFILE "Desktop\results.txt"
$depthext = 2

#END OF DEFAULTS




#What this is:
#Menu

#Explanation
#This section of the script creates the menu, by itself it will break because it doesn't have the loop.

#Creation Date:
#10/10/2026


function Show-Menu {
    #Removes text
    Clear-Host
    #You must go through each option to set the variables before you can run the search
    #uses a variable and will automatically update with the value set by the user
    #Displays the root selected.
    Write-Host " 1. Root selected: [Current: $rootset]"

    #Sets keywords to search for
    #stores if ($keywords.Count -gt 0) inside of $keyword variable
    $keyword = if ($keywords.Count -gt 0) {
        $keywords -join ', '
    } else {
        'None'
    }
    #Uses a variable and will automatically update with the value set by the user.
    #Displays the keywords selected.
    Write-Host " 2. Set Search Keywords    [Current: $keyword]"

    #Uses a variable and will automatically update with the value set by the user.
    #Displays the output file path selected.
    Write-Host " 3. Set Output File Path   [Current: $out]"
    #In the case of the depth being set to 0, this will append it so that depth is displayed as infinite, otherwise it will display the number selected.
    $depshow = if ($depthext -eq 0) {
        'Infinite'
    } else {
        $depthext
    }
    #Uses a variable and will automatically update with the value set by the user
    #Displays the max search depth selected.
    Write-Host " 4. Set Max Search Depth   [Current: $depshow]"
    
    #Writes the next option and when selected will execute the search with the current settings
    #Jumps down to the Invoke-Search function and executes the search
    Write-Host " 5. EXECUTE SEARCH"
    Write-Host " 6. Exit"
}

#END OF FIRST FUNCTION




#What this is:
#Search tool

#Explanation
#This is the actual search tool used on the second part of the script.
#If you go down to the loop section you'll see that when opt5 is entered it will use this function to execute the search.

#Creation Date:
#10/10/2026


function Invoke-Search {
    #Ensures a root directory is selected properly.
    if (-not (Test-Path -LiteralPath $rootset -PathType Container)) {
        Write-Host "Error: Invalid or missing root directory." 
        Pause
        return
    }
    #Ensures keywords are selected.
    if ($keywords.Count -eq 0) {
        Write-Host "Error: No search keywords provided."
        Pause
        return
    }

    #Ensures an output path is selected.
    #Uses try, catch, throw for error handling.
    #In short: Script try's a command, if it fails it will throw an error, then it will catch the error and display a message.
    #When initially testing this script I falled back on my Lua knowledge using if, else, etc. logic but without the try, catch, and throw logic the script would break.
    #Decided to try this logic after reading documentation on Powershell scripting.
    try {
        $directoryout = Split-Path -Parent $out

        if ([string]::IsNullOrWhiteSpace($out)) {
            throw "Output path cannot be empty."
        }
        #Ensures path exists, while checking logic with the -and operator, and prevents the output file from being displayed in the Terminal by piping it through Out-Null.
        if ($directoryout -and -not (Test-Path -LiteralPath $directoryout)) {
            New-Item -ItemType Directory -Path $directoryout -Force -ErrorAction Stop | Out-Null
        }

        #Creates the output file, uses utf8 encoding so the txt file is readable.
        #-ErrorAction Stop allows it to be thrown back to the try, catch, throw logic.
        #Uses a subexpression to get the current date and time and append it to the output file.
        Set-Content -LiteralPath $out -Value "Search Results - $(Get-Date)" -Encoding utf8 -ErrorAction Stop
    }
    catch {
        #Uses a subexpression, represents the object usinng "$_" and grabs the exception message and displays it to the user.
        Write-Host "Error: Unable to initialize output file: $($_.Exception.Message)" 
        Pause
        return
    }

    Write-Host "Searching..." 

    #Config
    #Creates a hashtable and stores it inside the variable.
    #Specifies the path with LiteralPath
    #Enables -File
    #Supresses errors. (This just makes it more clean cause constant error throwing gets very annoying.)
    $depthparamaters = @{
        LiteralPath = $rootset
        File        = $true
        ErrorAction = 'SilentlyContinue'
    }
    #Using if else logic for when depth is greater than 0 ['Depth'] = $depthext is used if it is not ['Recurse'] = $true executes.
    #Follows the logic in the initial Configuration.
    if ($depthext -gt 0) {
        $depthparamaters['Depth'] = $depthext
    } else {
        $depthparamaters['Recurse'] = $true
    }
    #Grabs the things requested after initial config is done in the Loop section.
    $files = Get-ChildItem @depthparamaters
    #Counts the amount of files found.
    $matco = 0

    #This is a sub-loop for this script which looks through the files and then sends it through a catch for error handling.
   foreach ($file in $files) {
    try {
        $matched = $false

        #Start search to find keywords in filename and/or extension.
        #This is also a sub-loop.
        foreach ($kw in $keywords) {

            #Check keyword in filename.
            #This intergrates .NET which helps with increased searching. (As you can see I've explored a lot of documentation.)
            #If text isn't found it returns a -1.
            #Returns a number where the keyword starts.
            #[System.StringComparison]::OrdinalIgnoreCase) makes it so case is ignored.
            if ($file.Name.IndexOf($kw, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                #Confirms matched keyword.
                $matched = $true
                #Exits sub-loop when keyword is found.
                break
            }

            #Check keyword in file extension.
            #Does the same .NET intergration.
            #Changes integration by not using numbers.
            if ($file.Extension.Equals($kw, [System.StringComparison]::OrdinalIgnoreCase)) {
                #Confirms matched keyword.
                $matched = $true
                #Exits sub-loop when keyword is found.
                break
            }
        }

        #Searches inside files.
        #Every single operator, cmdlet, and variable does a different thing.
        #Select-String searches for the keyword, -LiteralPath $file.FullName specifies, -Pattern $keywords sets what keywords to look for by checking the array
        #-SimpleMatch ensures that keywords are treated as strings, -Quiet handles the boolean result, and when an error occurs -ErrorAction SilentlyContinue supresses the errors.
        if (-not $matched) {
            $matched = (Select-String -LiteralPath $file.FullName -Pattern $keywords -SimpleMatch -Quiet -ErrorAction SilentlyContinue)
        }

        #Saving.
        #Creates the .txt file and makes sure that errors fall back on catch.
        if ($matched) {
            Add-Content -LiteralPath $out -Value $file.FullName -Encoding utf8 -ErrorAction Stop
            #Displays on screen that a match was found.
            Write-Host "MATCH FOUND: $($file.FullName)"
            #Match counter so that final count is given for files found.
            $matco = $matco + 1
        }
    }
    catch {
        #Skip files that cannot be read or processed.
        continue
    }
}
    #Displays results and informs user of where the output is saved.
    Write-Host "Search complete, I've found $matco matching file(s)." 
    Write-Host "Results saved to: $out"
    
    # Requires the user to press enter to continue.
    #Apparently this comment above needed a space due to the code above. Annoying.
    Pause
}

#END OF SECOND FUCNTION









#What this is:
#Loop


#Explanation:

# This is the actual menu of the script, loops until opt6 selected
# You'll see this menu is similar to the menu I made in Lab 5, guess where i copied the logic from and translated it for this use case ;)
#However it's a bit more complicated...
#I'm keeping this loop at the bottom because it's way more dificult to be able to initalize, by keeping it at the bottom I don't have to do more work.

#Creation Date:
#10/9/2026

#Start of Loop using do-while. This keeps the menu up.
do {
    Show-Menu
    #Reads what number is input and then jumps to switch section.
    $choice = Read-Host "Enter option (1-6)"

    #Allows for different items to be switched to.
    switch ($choice) {
        "1" {
            $in = Read-Host "Enter folder to scan."
            #Following similar logic as before with earlier functions just adapted to the specific need for this part of the script. Purely validation and error handling.
            if (Test-Path -LiteralPath $in -PathType Container -ErrorAction SilentlyContinue) {
                $rootset = (Get-Item -LiteralPath $in).FullName
                #If a folder path isn't correct then it will not update.
            } else {
                Write-Host "Folder selection incorrect."
                Start-Sleep -Seconds 1
            }
        }

        "2" {
            #Reads the keywords inputed.
            $keyraw = Read-Host "Enter keywords to search for (seperate multiple keywords with commas)"
            #Checks for an empty input and if it is not an empty input it will append the $keywords variable under the else statement with the array for the keywords.
            if (-not [string]::IsNullOrWhiteSpace($keyraw)) {
                $keywords = @(
                    #allows for splitting keywords apart by commas
                    #Removes the spaces.
                    #Removes any keywords that are just a space.
                    $keyraw.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
                )
            } else {
                $keywords = @()
            }
        }

        "3" {
            $inout = Read-Host "Enter the directory including what you want to call the output text file."
            #Similarly removes spaces for the directory chosen but also adds to the variable so that functions above can be used.
            if (-not [string]::IsNullOrWhiteSpace($inout)) {
                $out = $inout.Trim()
            }
        }

        "4" {
            $depin = Read-Host "Select the search depth (enter 0 for an infinite search)"

            #Uses regex to make the number chosen an integer.
            if ($depin -match '^\d+$') {
                #Input turns into a integer.
                $depthext = [int]$depin
            } else {
                #Ensures that a number is actually given.
                Write-Host "Incorrect number. Enter a valid search depth."
                #Similar to timeout in batchfiles
                Start-Sleep -Seconds 1
            }
        }

        "5" {
            #Starts the search.
            Invoke-Search
        }

        "6" {
            Write-Host "Exiting system search program..."
            #Similar to timeout in batchfiles
            Start-Sleep -Seconds 1
        }

        #Sets a default for if a option is selected that doesn't exist.
        default {
            Write-Host "Incorrect selection, choose a number 1-6."
            #Similar to timeout in batchfiles
            Start-Sleep -Seconds 1
        }
    }
#Forces repeat until option 6 is selected.
} while ($choice -ne "6")

#END OF LOOP
#END OF SCRIPT
