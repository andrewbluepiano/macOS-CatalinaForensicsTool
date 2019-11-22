# <img src="https://i.imgur.com/cGllffv.png" width="75" height="75" /> CatalinaForensicsTool 
A GUI frontend for AppleScript (shell, etc) based forensic artifact retreival. 

But what its really about is providing a building block so, so anyone can add in stuff, make it their own. Its not exactly simple to get Cocoa, and AppleScript talking to terminal, and now calling python stuff is in there too. This app lays things out pretty understandably. Just be aware of how things are delegated and assigned, and you shouldnt have a problem adding on. 

DOES NOT USE SANDBOX. 

Relies on AppleScriptObjC for operation. 

FS Event Parsing uses python. 

Requires various permissions. 

If you are not prepared to debug any minor quirks / build failures from things in progress, stick with the releases tab. Those have actually been tested and are bookmarked for functionality. They're not actually "releases". 

This is not indended to be a standard consumer / production app, as its operation violates many core traits of normal macOS app operation. It is not malicious in any way, just not something the average Jill/Joe should be messing around with in general. 

Much more functionality would be availible in a version designed to run with SIP disabled. 

### Known Quirk(s)
* The check password function isnt exactly working as expected. If you dont enter the right password in the main window it wont tell you right now. It just wont display the "Auth Success" notification, and it wont be able to get all the data. 

## Two ways to run:
1. Compile it yourself! (BETTER, SAFER WAY. You should check what a program like this is doing)
2. Download the release .app and run the following command on the file:
xattr -cr CatalinaExporter.app

## Screenshot of Current (Release) State
![Screen Shot](https://i.imgur.com/DTmp9de.png)


## Credits:
* David Cowen's FSEventParser used for FSEvent Exporting: https://github.com/dlcowen/FSEventsParser <br>
(Yes, that means the script now shows you how to trigger python stuff. From withing a Cocoa app. Using AppleScript. Pretty mind blowing stuff, huh. 😂)
