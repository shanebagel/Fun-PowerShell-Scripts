<#
.SYNOPSIS 
Rebuilds windows profile, copies all files from users old profile

.DESCRIPTION
Rebuilds windows profile by removing registry keys: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\ProfileList
Reboots the computer, logs in with user credentials to create new profile, transfers data from old profile into new profile 

.PARAMETER Identity
Username of the profile being rebuilt

.PARAMETER ComputerName
Hostname of the machine you're running the script against

.PARAMETER Credential
Credential of the user that script will use to sign back into the workstation with

.EXAMPLE
Start-ProfileRebuild -ComputerName "ShaneClient" -Identity "Shane" 

.NOTES
Must be ran before Move-ProfileData.psm1

#>
[CmdletBinding()]
Param (
    [Parameter(ValueFromPipeline=$True)]
    [PSCredential]$Credential,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [String]$ComputerName,

    [Parameter(ValueFromPipeline=$True)]
    [String]$Identity
)

function Start-ProfileRebuild {

Invoke-Command -ComputerName $ComputerName -ScriptBlock {Restart-Computer}

while ($Online -ne $null){

Write-Output "oops"
}

<#

1. Reboot the computer to release any locks on the profile. - add a check to see if machine was rebooted
3. Navigate to the users profile C:\Users\<UserProfile>
4. Rename the user profile with the word “old”. Example: “username” becomes “OLD-username”
5. Delete registry key for that user: Open regedit.exe and navigate to: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\ProfileList
Find the key that lists the user name. Then delete it. You need to delete the entire folder. 

HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\ProfileList

The entire SID folder must be deleted for the user

6. Reboot the computer again.

#>
}



<#
.SYNOPSIS 

.DESCRIPTION

.PARAMETER Identity

.PARAMETER ComputerName

.PARAMETER Credential

.EXAMPLE

.NOTES
Must be ran after Initialize-ProfileRebuild.psm1

#>








