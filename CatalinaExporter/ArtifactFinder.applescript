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
    property diagReport : false
	property systStartItems : false
    
    -- ToolTips, Offer explanation of options when hovered over
    property sysTip : "This will gather the system information displayed in system profiler."
    property unifTip : "Exports the entirety of the unified log. The file will likely be over 1GB."
    property instHistTip : "History of installed Applications and Updates"
    property fseventTip : "Exports the FSEvents data as a sqlite db from /.fseventsd/ using David Cowen's FSEventsParser\nhttps://github.com/dlcowen/FSEventsParser\nWARNING: This one takes a while."
    property getMetaTip : "Because spotlight databases are encrypted, and there is no known reversing method (Papers have been written on the topic).\n\nWe accomplish a backup of file metadata by recursively applying the 'MDLS' command. \n\nYou will be promted for the directory whose contents metadata you want to export."
    property systStartItemTip : "Collects configurations for system wide startup items from:\n/Library/StartupItems/\n/System/Library/StartupItems/"
    property diagreportTips : "This will gather the diagnostic reports on the system."
 
    -- Runs when the 'choose output folder' button is pressed.
	on setup:sender
        set outputLocation to ((POSIX path of (choose folder with prompt "Please select an output folder:")) as string) & "CatalinaArtifacts/"
        try
            do shell script "/bin/ls " & outputLocation
            display dialog "Existing export detected in that location. Please choose a new one. The program isnt smart enough to deal with this yet."
            -- display notification "Old folder detected, removing" with title "Progress Alert"
        on error errMsg number errorNumber
            -- display dialog ("Error occurred:  " & errMsg as text) & " Num: " & errorNumber as text
            display notification "Creating new output folder" with title "Progress Alert"
            delay 1
            do shell script "/bin/mkdir " & outputLocation
            outputLocationField's setStringValue_(outputLocation)
            timeStamp(outputLocation, "Program Start Time", startTime)
        end try
    end setup:
    
    on testWindow:sender
        -- Debugging
        display alert "This does nothing unless you tell it what to do."
    end testWindow:
    
    -- Function to check if provided password is valid
    on checkPasswd:sender
        set shellPassword to shellPasswordField's stringValue() as text
        try
            do shell script "pwpolicy -p " & shellPassword & " enableuser"
            do shell script "/bin/echo" with administrator privileges
            display notification "Auth Success"
            delay 1
        on error errMsg number errorNumber
            -- display dialog ("Error occurred:  " & errMsg as text) & " Num: " & errorNumber as text
            display alert "Sorry, you've entered an invalid password. Please try again."
        end try
    end checkPasswd:
    
    -- System Profile Function
    on systemProfile(sysInfo, outputLocation, shellPassword)
        if sysInfo as boolean then
            set fileLocation to outputLocation & "SystemInformation/"
            set sysProfTime to current date
            do shell script "mkdir " & fileLocation & " && system_profiler -detailLevel full -xml > " & fileLocation & "SystemProfile.spx"
            timeStamp(outputLocation, "SystemProfile.spx", sysProfTime)
            display notification "System Profiled"
        end if
    end systemProfile
    
    -- Unified Logs Function
    on getUnifLogs(unifLogs, outputLocation, shellPassword)
        if unifLogs as boolean then
            set fileLocation to outputLocation & "UnifiedLogs/"
            set unifLogTime to current date
            do shell script "mkdir " & fileLocation & " && log collect --output " & fileLocation & "unifLogs.logarchive" password shellPassword with administrator privileges
            timeStamp(outputLocation, "unifLogs.logarchive", unifLogTime)
            display notification "Logs Unified"
        end if
    end getLogs
    
    -- Install History Function
    on getInstallHist(instHist, outputLocation, shellPassword)
        if instHist as boolean then
            set fileLocation to outputLocation & "InstallationHistory/"
            set instHistTime to current date
            -- p flag must be used for CP to keep metadata intact.
            do shell script "mkdir " & fileLocation & " && cp -p /Library/Receipts/InstallHistory.plist " & fileLocation
            timeStamp(outputLocation, "InstallHistory.plist", instHistTime)
        end if
    end getInstallHist
    
    -- Get system startup items function
    on getSystStartItems(systStartItems, outputLocation, shellPassword)
        if systStartItems as boolean then
			set fileLocationZero to outputLocation & "SystemStartupItems/"
            set fileLocationOne to outputLocation & "SystemStartupItems/Library-StartupItems/"
            set fileLocationTwo to outputLocation & "SystemStartupItems/System-Library-StartupItems/"
            set getSystemStartItemsTime to current date
            -- p flag must be used for CP to keep metadata intact.
			do shell script "mkdir " & fileLocationZero & ""
            do shell script "mkdir " & fileLocationOne & " && cp -p -r /Library/StartupItems/ " & fileLocationOne
            do shell script "mkdir " & fileLocationTwo & " && cp -p -r /System/Library/StartupItems/ " & fileLocationTwo
            timeStamp(outputLocation, "System StartupItems", getSystemStartItemsTime)
        end if
    end getSystStartItems
    
    -- Parse FS Events Function
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
    
    -- Retrieve Metadata function
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
    
    -- Get Diagnostics Reports
    on getDiagnosticReports(diagReport, outputLocation, shellPassword)
        if diagReport as boolean then
            set fileLocation to outputLocation & "/DiagnosticReports"
            set diagReportTime to current date
            -- p flag must be used for CP to keep metadata intact.
            do shell script "mkdir " & fileLocation & " && cp -pr /Library/Logs/DiagnosticReports " & fileLocation
            timeStamp(outputLocation, "DiagnosticReports", diagReportTime)
        end if
    end getDiagnosticReports
    
    -- Time Stamp Function
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
        getDiagnosticReports(diagReport, outputLocation, shellPassword)
        fsEventsParse(fsEvents, outputLocation, shellPassword)
        getMetaData(getMeta, outputLocation, shellPassword)
        getSystStartItems(systStartItems, outputLocation, shellPassword)
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
    
    on diagReportCheck:sender
        set diagReport to sender's intValue()
    end diagReportCheck:
    
    on systStartItemsCheck:sender
        set systStartItems to sender's intValue()
    end systStartItemsCheck:
end script
