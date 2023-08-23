function Move-ProfileData {





Write-Output "7. Login with the users credentials and windows will create a new user profile."
<#


8. Transfer data from the user’s old profile (OLD-username) into the users new profile (username) one folder at a time. 
	• Do not transfer the “AppData” contents unless you specifically know what you are looking for. This folder is most likely housing the garbage that jacked-up the user profile in the first place. 
	• Don't delete the old profile folder. Just in case.
9. Reboot once more.
10. Have user login again.
11. Sign into all office apps (OneDrive/Teams/Microsoft Office Suite)
12. Remap task bar items and any other cosmetics that aren't pushed by GPO
13. Remap quick access folders (copy files over from old profile) %appdata%\roaming\microsoft\windows\recent\automaticdestinations
14. Make sure user can access SharePoint sites online
15. Remap SharePoint sites to File Explorer
16. Setup OneDrive to backup Desktop/Documents/Pictures directories
17. Set default apps
18. Copy bookmarks/browser data for web browser from old profile 
19. Sign into Gmail account for Google Chrome
20. Recreate outlook signatures
21. Re-add network drives (if not pushed by GPO)
22. Re-add printers (if not pushed by GPO)

Useful Locations to copy over when rebuilding Profile:

User Profile Registry Key Location	HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\ProfileList
File explorer Quick Access locations	C:\Users\%username%\%Appdata%\microsoft\windows\recent\automaticdestinations
Google Chrome Data File Location	C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default 
MS Edge Data File Location	C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default
Mozilla Firefox Data File Location	C:\Users\%username%\%AppData%\Mozilla\Firefox\Profiles\
Outlook Signature File Location	C:\Users\%username%\AppData\Roaming\Microsoft\Signatures
OneNote File Location (Everything)	C:\Users\%username%\AppData\Local\Packages\Microsoft.Office.OneNote_8wekyb3d8bbwe
OneNote "Backup" File Location	C:\Users\%username%\AppData\Local\Microsoft\OneNote\16.0\Backup
Windows Credential Manager File Location 	C:\Users\%username%\AppData\Local\Microsoft\Vault
Outlook Data File Location	C:\Users\%username%\AppData\Local\Microsoft\Outlook
Taskbar File Location	C:\Users\%username%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar

#>

}