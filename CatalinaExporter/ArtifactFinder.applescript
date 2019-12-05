-- Author: Andrew Afonso
-- https://github.com/andrewbluepiano/macOS-CatalinaForensicsTool/
-- FSEParser Author, Owner: David Cowen
-- https://github.com/dlcowen/FSEventsParser
use framework "Foundation"
use framework "OSAKit"
use scripting additions

script ArtifactFinder
	
	property parent : class "NSObject"
	
	-- Store these values for use in other method calls
	property shellPassword : missing value
    property shellPasswordField : missing value
    -- outputLocation is string of selected path plus CatalinaArtifacts/
	property outputLocation : missing value
    property outputLocationField : missing value
    property startTime : current date
    
    -- Checkboxes
    property sysInfo : false
    property unifLogs : false
    property instHist : false
    property fsEvents : false
    property getMeta : false
    property startItems : false
    
    -- ToolTips, Offer explanation of options when hovered over
    property sysTip : "This will gather the system information displayed in system profiler."
    property unifTip : "Exports the entirety of the unified log. The file will likely be over 1GB."
    property instHistTip : "History of installed Applications and Updates"
    property fseventTip : "Exports the FSEvents data as a sqlite db from /.fseventsd/ using David Cowen's FSEventsParser\nhttps://github.com/dlcowen/FSEventsParser\nWARNING: This one takes a while."
    property getMetaTip : "Because spotlight databases are encrypted, and there is no known reversing method (Papers have been written on the topic).\n\nWe accomplish a backup of file metadata by recursively applying the 'MDLS' command. \n\nYou will be promted for the directory whose contents metadata you want to export."
    property startItemTip : "items designated to load when you start your Mac"
 
    -- Runs when the 'choose output folder' button is pressed.
	on setup:sender
        -- Todo: Add in setup to allow users to enter case / project name, check if directory already exists, etc
        set outputLocation to ((POSIX path of (choose folder with prompt "Please select an output folder:")) as string) & "CatalinaArtifacts/"
        outputLocationField's setStringValue_(outputLocation)
        -- TRY BELOW FOR DEVELOPMENT ONLY, DONT LEAVE IN WHEN SUBMITTED, COULD CAUSE FORENSIC DATA DELETION OF EXISTING CASES
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
        timeStamp(outputLocation, "Program Start Time", startTime)
    end setup:
    
    on testWindow:sender
        set appLocation to (quoted form of ((current application's NSBundle's mainBundle()'s resourcePath() as text) & "/subScripts/pwTester.sh"))
        display dialog appLocation
        set theResponse to (display dialog "What's your name?" default answer "" with icon stop buttons {"Cancel", "Continue"} default button "Continue" with hidden answer)
        set theusser to (display dialog "What's your username?" default answer "" with icon stop buttons {"Cancel", "Continue"} default button "Continue")
        try
            do shell script "sudo -K"
            set output to do shell script "sudo -n /bin/echo \"cat\"" user name theusser password theResponse
            display dialog output
            set the_script to "echo Hello World"
            set the_result to do shell script the_script
        on error errMsg number errorNumber
            display dialog ("Error occurred:  " & errMsg as text) & " Num: " & errorNumber as text
        end try
        -- Debugging
        display alert "This does nothing unless you tell it what to do."
    end testWindow:
    
    on checkPasswd:sender
        set shellPassword to shellPasswordField's stringValue() as text
        set scriptLocation to (quoted form of ((current application's NSBundle's mainBundle()'s resourcePath() as text) & "/subScripts/pwTester.sh"))
        try
            do shell script "sudo -K"
            set output to (do shell script "sh " & scriptLocation & " " & shellPassword)
            display notification "Auth Success"
            delay 1
        on error errMsg number errorNumber
            -- display alert "Debugging alert error occurred:  " & errMsg as text & " Num: " & errorNumber as text
            display alert "Sorry, you've entered an invalid password. Please try again."
        end try
    end checkPasswd:
    
    on systemProfile(sysInfo, outputLocation, shellPassword)
        if sysInfo as boolean then
            set fileLocation to outputLocation & "SystemInformation/"
            set sysProfTime to current date
            do shell script "mkdir " & fileLocation & " && system_profiler -detailLevel full -xml > " & fileLocation & "SystemProfile.spx"
            timeStamp(outputLocation, "SystemProfile.spx", sysProfTime)
            display notification "System Profiled"
        end if
    end systemProfile
    
    on getUnifLogs(unifLogs, outputLocation, shellPassword)
        if unifLogs as boolean then
            set fileLocation to outputLocation & "UnifiedLogs/"
            set unifLogTime to current date
            do shell script "mkdir " & fileLocation & " && log collect --output " & fileLocation & "unifLogs.logarchive" password shellPassword with administrator privileges
            timeStamp(outputLocation, "unifLogs.logarchive", unifLogTime)
            display notification "Logs Unified"
        end if
    end getLogs
    
    on getInstallHist(instHist, outputLocation, shellPassword)
        if instHist as boolean then
            set fileLocation to outputLocation & "InstallationHistory/"
            set instHistTime to current date
            -- p flag must be used for CP to keep metadata intact.
            do shell script "mkdir " & fileLocation & " && cp -p /Library/Receipts/InstallHistory.plist " & fileLocation
            timeStamp(outputLocation, "InstallHistory.plist", instHistTime)
        end if
    end getInstallHist
    
    on getStartItems(startItems, outputLocation, shellPassword)
        if startItems as boolean then
            set fileLocation to outputLocation & "StartupItems/"
            set getStartItemsTime to current date
            -- p flag must be used for CP to keep metadata intact.
            -- do shell script "mkdir " & fileLocation & " && cp -p -r /Library/StartupItems/ " & fileLocation
            timeStamp(outputLocation, "InstallHistory.plist", getStartItemsTime)
        end if
    end getStartItems
    
    on fsEventsParse(fsEvents, outputLocation, shellPassword)
        if fsEvents as boolean then
            set fileLocation to outputLocation & "FSEventsData/"
            set fsEventTime to current date
            set appLocation to current application's NSBundle's mainBundle()'s resourcePath() as text
            do shell script "mkdir " & fileLocation
            set theCommand to ((quoted form of (appLocation & "/FSEventsParser/FSEParser_V4")) & " -s /.fseventsd/ -o " & fileLocation & " -t folder")
            do shell script theCommand password shellPassword with administrator privileges
            timeStamp(outputLocation, "FSEventsData", fsEventTime)
        end if
    end fsEventsParse
    
    on getMetaData(getMeta, outputLocation, shellPassword)
        -- maybe PlistBuddy needs to get involved
        if getMeta as boolean then
            display alert  "METADATA FUNCTION WARNING" message "This function is recursive throughout the entire directory selected. It will follow aliases, symlinks, whatever. So this will take a long time for folders with lots of items. \n\nIf you select a directory whose contents you arent aware of, there is a high potential to end up scanning the entire filesystem. \n\n Also, this function is a bit wonky. MDLS didnt want to accept the 'with administrator permissions' flag. So that didnt happen. I dont know how much that will effect what this is able to record.\n\nBe careful, youve been warned.\n\n "
            set metaDataStartTime to current date
            set fileLocation to outputLocation & "MetaData/"
            set outputFileLocation to outputLocation & "MetaData/metadata.plist"
            do shell script "mkdir " & fileLocation
            set appLocation to (current application's NSBundle's mainBundle()'s resourcePath() as text)
            set scriptLocation to appLocation & "/subScripts/getEverything.scpt"
            set getEverything to load script current application's POSIX file scriptLocation

            tell getEverything
                set allContents to runGet()
            end tell
            -- everything is POSIX paths of stuff

            -- set metaDataDict to {}

            tell application "System Events"
                set metaDataDict to make new property list item with properties {kind:record}
                set metaDataFilePath to (fileLocation & "MetaData.plist")
                set metaDataFile to make new property list file with properties {contents:metaDataDict, name:metaDataFilePath}
            end tell
            
            set a to 0
            
            repeat with oneFile in allContents
                -- display alert (quoted form of oneFile)
                set mdlsCmd to ("mdls " & quoted form of oneFile & " -plist " & quoted form of (appLocation & "/tmp.plist"))
                try
                    do shell script mdlsCmd
                    do shell script "/usr/libexec/PlistBuddy -c \"Add :" & a & " dict\" " & outputFileLocation
                    do shell script "/usr/libexec/PlistBuddy -c \"Add :" & a & ":FilePath string "& quoted form of oneFile &"\"  " & outputFileLocation
                    do shell script "/usr/libexec/PlistBuddy -c \"Merge " & quoted form of (appLocation & "/tmp.plist") & " :" & a & " \" " & outputFileLocation
                    set a to (a + 1)
                on error errMsg number errorNumber
                    -- display notification "Error occurred:  " & errMsg as text & " Num: " & errorNumber as text
                end try
            end repeat
            timeStamp(outputLocation, "metadata backup start time", metaDataStartTime)
        end if
    end getMetaData
    
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
        getInstallHist(instHist, outputLocation, shellPassword)
        fsEventsParse(fsEvents, outputLocation, shellPassword)
        getMetaData(getMeta, outputLocation, shellPassword)
        getStartItems(startItems, outputLocation, shellPassword)
        display alert "Done"
    end mainStuff:
    
    -- Checkbox Handelers
    on sysInfoCheck:sender
        set sysInfo to sender's intValue()
    end sysInfoCheck:
    
    on unifLogsCheck:sender
        set unifLogs to sender's intValue()
    end unifLogsCheck:
    
    on instHistCheck:sender
        set instHist to sender's intValue()
    end instHistCheck:
    
    on fseventsCheck:sender
        set fsEvents to sender's intValue()
    end fseventsCheck:
    
    on getMetaCheck:sender
        set getMeta to sender's intValue()
    end getMetaCheck:
    
    on startItemsCheck:sender
        set startItems to sender's intValue()
    end startItemsCheck:
end script
