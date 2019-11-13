# CatalinaForensicsTool
![Screen Shot](https://imgur.com/BQYpGkC)
A GUI frontend for AppleScript (shell, etc) based forensic artifact retreival. 

Heavily relies on AppleScriptObjC for operation. 

DOES NOT USE SANDBOX. 

This is not indended to be a consumer / production app, as its operation violates many core traits of normal macOS app operation. It is not malicious in any way, just not something the average Jill/Joe should be messing around with in general. 

# To run:
1. Compile it yourself!
2. Download the release .app and run the following command on the file:
xattr -cr CatalinaExporter.app
