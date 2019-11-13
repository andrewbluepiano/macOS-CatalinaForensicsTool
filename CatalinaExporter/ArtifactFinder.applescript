-- A nice base for the project.
use framework "Foundation"
use framework "OSAKit"
use scripting additions


script ArtifactFinder
	
	property parent : class "NSObject"
	
	-- Store these values for use in othere method calls
	property shellPassword : missing value
    property shellPasswordField : missing value
	property outputLocation : missing value
    property outputLocationField : missing value
    
    
    -- Checkboxes
    property sysInfo : missing value
	
	on setup:sender
        -- Todo: Add in setup to allow users to enter case / project name, check if directory already exists, etc
        set outputLocation to choose folder with prompt "Please select an output folder:"
        set outputLocation to POSIX path of outputLocation
        set outputLocation to outputLocation as string
        set outputLocation to outputLocation & "CatalinaArtifacts/"
        outputLocationField's setStringValue_(outputLocation)
        -- TRY BELOW FOR DEVELOPMENT ONLY, DONT LEAVE IN WHEN SUBMITTED
        try
            do shell script "/bin/ls " & outputLocation
            display alert "Old folder detected, removing"
            do shell script "/bin/rm -rf " & outputLocation
        on error errMsg number errorNumber
            -- display dialog "Error occurred:  " & errMsg as text & " Num: " & errorNumber as text
        end try
        display alert "Creating new output folder"
        do shell script "/bin/mkdir " & outputLocation
    end setup:
    
    on testWindow:sender
        -- To test applescript variables, as theres odd nonsense getting the storage persistant.
        -- display dialog shellPassword
        display alert outputLocation
    end testWindow:
    
    on checkPasswd:sender
        set shellPassword to shellPasswordField's stringValue() as text
        try
            do shell script "sudo -K"
            do shell script "/bin/echo" password shellPassword with administrator privileges
            display alert "Auth Success"
            return 1
        on error errMsg number errorNumber
            display dialog "Debugging alert error occurred:  " & errMsg as text & " Num: " & errorNumber as text
            --display alert "Sorry, you've entered an invalid password. Please try again."
            return 0
        end try
    end checkPasswd:
    
    on mainStuff:sender
        if sysInfo as boolean then
            set outFile to outputLocation & "SysInfo.txt"
            do shell script "system_profiler -detailLevel basic -xml > " & outputLocation & "/SystemProfile.spx"
            --set myFile to open for access outFile with write permission
            --write (get system info) to myFile
            --close access myFile
        end if
    end mainStuff:
    
    -- Checkbox Handelers
    on sysInfoCheck:sender
        -- TODO: Add in selecter for basic mini full report
        set sysInfo to sender's intValue()
    end sysInfoCheck:
end script
