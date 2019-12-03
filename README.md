# <img src="https://i.imgur.com/cGllffv.png" width="75" height="75" /> CatalinaForensicsTool 
A GUI frontend for AppleScript (shell, etc) based forensic artifact retreival. 

But what its really about is providing a building block so, so anyone can add in stuff, make it their own. Its not exactly simple to get Cocoa, and AppleScript talking to terminal, and using their own binaries. This app lays things out pretty understandably. Just be aware of how things are delegated and assigned, and you shouldnt have a problem adding on. The hardest part is getting familiar with Xcode. 

DOES NOT USE SANDBOX. 

Relies on AppleScriptObjC for operation. 

Requires various permissions.
* Full Disk Access
* System Events.app

If you are not prepared to debug any minor quirks / build failures from things in progress, stick with the releases tab. Those have actually been tested and are bookmarked for functionality. They're not actually "releases" as in full suites. 

This is not indended to be a standard consumer / production app, as its operation violates many core traits of normal macOS app operation. It is not malicious in any way, just not something the average Jill/Joe should be messing around with in general. 

## Big future plan:
There might be more stuff available in the protected volumes that can be mounted with SIP disabled. 

## Overall future functionality:
* Switch to a table view / stack view or some other scrollable method of displaying all the options
* Add in easy way for users to create their own functions via gui
	* Take the existing functions, break down to what their core operations are, and provide those as templates to users. Have new functions do a test run before adding them to confirm its expected behavior. Ex:
		* Select the type of output, show different options for managing the output of various types (txt, plist, xml, sqlite, etc)
		* Set output folder subdir name
		* Set tooltip
		* Admin (y/n) each line
		* When to timestamp in function flow
		* Manual or '>' output redirection. 
* [] Detect if additional instances are running. 


### Known Quirk(s)
* Dont open more than one instance. Doing so sometimes crashes system. 
* The check password function isnt exactly working as expected. If you dont enter the right password in the main window it wont tell you right now. It just wont display the "Auth Success" notification, and it wont be able to get all the data. 
  * Planned fix method:
    1. Ideal fix would to be to automate entering the password from the main window into the popup asking for creds, but I would hope thats not possible to automate with AppleScript for several reasons. But if it is, and there is a secure way to do that, develemontally speaking that would be ideal. 
    2. More likely to be just changing the the password check function works. 

## Two ways to run:
1. Compile it yourself! (BETTER, SAFER WAY. You should check what a program like this is doing)
2. Download the release .app and run the following command on the file:
xattr -cr CatalinaExporter.app
3. You must give CatalinaExporter.app full disk access for some functions to work. 

## Screenshot of Current (Release) State
![Screen Shot](https://i.imgur.com/vWfg3XB.png)


## Credits:
* David Cowen's FSEventParser used for FSEvent Exporting: https://github.com/dlcowen/FSEventsParser <br>
