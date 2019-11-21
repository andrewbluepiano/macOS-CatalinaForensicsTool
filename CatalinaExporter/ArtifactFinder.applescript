-- A nice base for the project.
use framework "Foundation"
use framework "OSAKit"
use scripting additions

script ArtifactFinder
	
	property parent : class "NSObject"
	
	-- Store these values for use in other method calls
	property shellPassword : missing value
    property shellPasswordField : missing value
	property outputLocation : missing value
    property outputLocationField : missing value
    property startTime : current date
    
    -- Checkboxes
    property sysInfo : false
    property unifLogs : false
    
    -- ToolTips, Offer explanation of options when hovered over
    property sysTip : "This will gather the system information displayed in system profiler."
    property unifTip : "Exports the entirety of the unified log. The file will likely be over 1GB."
 
	on setup:sender
        -- Todo: Add in setup to allow users to enter case / project name, check if directory already exists, etc
        set outputLocation to choose folder with prompt "Please select an output folder:"
        set outputLocation to POSIX path of outputLocation
        set outputLocation to outputLocation as string
        set outputLocation to outputLocation & "CatalinaArtifacts/"
        outputLocationField's setStringValue_(outputLocation)
        -- TRY BELOW FOR DEVELOPMENT ONLY, DONT LEAVE IN WHEN SUBMITTED, COULD CAUSE FORENSIC DATA DELETION
        try
            do shell script "/bin/ls " & outputLocation
            -- display notification "Old folder detected, removing" with title "Progress Alert"
            do shell script "/bin/rm -rf " & outputLocation
        on error errMsg number errorNumber
            -- display dialog "Error occurred:  " & errMsg as text & " Num: " & errorNumber as text
        end try
        display notification "Creating new output folder" with title "Progress Alert"
        delay 1
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
            display notification "Auth Success"
            delay 1
            return 1
        on error errMsg number errorNumber
            display dialog "Debugging alert error occurred:  " & errMsg as text & " Num: " & errorNumber as text
            --display alert "Sorry, you've entered an invalid password. Please try again."
            return 0
        end try
    end checkPasswd:
    
    on systemProfile(sysInfo, outputLocation, shellPassword)
        if sysInfo as boolean then
            --set outFile to outputLocation & "SysInfo.txt"
            do shell script "system_profiler -detailLevel basic -xml > " & outputLocation & "/SystemProfile.spx"
            set sysProfTime to current date
            display notification "System Profiled"
            --set myFile to open for access outFile with write permission
            --write (get system info) to myFile
            --close access myFile
            timeStamp(outputLocation, "SystemProfile.spx", sysProfTime)
        end if
    end systemProfile
    
    on getUnifLogs(unifLogs, outputLocation, shellPassword)
        if unifLogs as boolean then
            set unifLogTime to current date
            do shell script "log collect --output " & outputLocation & "unifLogs.logarchive" password shellPassword with administrator privileges
            timeStamp(outputLocation, "unifLogs.logarchive", unifLogTime)
        end if
    end getLogs
    
    on timeStamp(outputLocation, artName, artGetTime)
        -- display alert outputLocation
        tell application "System Events"
            set timestampDict to make new property list item with properties {kind:record}
            set timestampFilePath to (outputLocation & "Timestamps.plist")
            if not (exists file timestampFilePath) then
                set timestampFile to make new property list file with properties {contents:timestampDict, name:timestampFilePath}
            else
                set timestampFile to property list file timestampFilePath
            end if
            
            tell property list items of timestampFile
                -- make new property list item at end with properties {kind:date, name:"Program Start Time", value:startTime}
                make new property list item at end with properties {kind:date, name:artName, value:artGetTime}
            end tell
        end tell
    end timeStamp
    
    
    -- The actual data collection stuff
    on mainStuff:sender
        systemProfile(sysInfo, outputLocation, shellPassword)
        getUnifLogs(unifLogs, outputLocation, shellPassword)
        display alert "Done"
    end mainStuff:
    
    -- Checkbox Handelers
    on sysInfoCheck:sender
        -- TODO: Add in selecter for basic mini full report
        set sysInfo to sender's intValue()
    end sysInfoCheck:
    
    on unifLogsCheck:sender
        -- TODO: Add in selecter for basic mini full report
        set unifLogs to sender's intValue()
    end unifLogsCheck:
end script
