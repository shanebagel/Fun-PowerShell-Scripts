function Move-ProfileData {

<#
.SYNOPSIS 
Migrates data stored in an old windows user profile to a new profile

.DESCRIPTION
Copies data in the following directories to the new profile:
File explorer quick access items
Google Chrome data 
MS Edge data 
Mozilla Firefox data
OneNote Files (Everything)
OneNote "Backup" Files
Windows Credential Manager Objects
Outlook Signature content
Taskbar File location 

Optionally: Outlook Data Files - use the IncludeOutlookData paramater 

.PARAMETER UserName
Username of the account you're running script against

.PARAMETER NewProfileName
New profile you're migrating data into

.PARAMETER ComputerName
Computer name of the machine that houses the profiles

.PARAMETER ProfileName
Old profile you're migrating data out of 

.PARAMETER IncludeOutlookData
If $true is passed in outlook data files will be copied over to new profile. By default outlook data files will not be included in move

.EXAMPLE
Move-ProfileData -ComputerName "Shaneserver" -ProfileName "OLD-bob" -NewProfileName "bob" -Username "bob"

.NOTES
Can be ran after Start-ProfileRebuild.ps1

#>

	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline = $True, Mandatory = $True)]
		[String]$ComputerName,

		[Parameter(Mandatory = $True)]
		[String]$NewProfileName,

		[Parameter(Mandatory = $True)]
		[String]$ProfileName,

		[Parameter(Mandatory = $True)]
		[String]$UserName,

		[Parameter(Mandatory = $False, ValidateNotNull)]
		[Boolean]$IncludeOutlookData

	) 

	begin {
		$TestCondition = (Test-Path "C:\Users\$ProfileName") -and (Test-Path "C:\Users\$NewProfileName")	
	}

	process {

		if ( $TestCondition ) {

			$SourcePaths = @( # Source file locations
				"C:\Users\$ProfileName\Desktop\*"
				"C:\Users\$ProfileName\Downloads\*"
				"C:\Users\$ProfileName\Documents\*"
				"C:\Users\$ProfileName\Pictures\*"
				"C:\Users\$ProfileName\Videos\*"
				"C:\Users\$ProfileName\Appdata\Roaming\microsoft\windows\recent\automaticdestinations\*"
				"C:\Users\$ProfileName\AppData\Local\Google\Chrome\User Data\Default\*"
				"C:\Users\$ProfileName\AppData\Local\Microsoft\Edge\User Data\Default\*"
				"C:\Users\$ProfileName\AppData\Roaming\Mozilla\Firefox\Profiles\*"
				"C:\Users\$ProfileName\AppData\local\Mozilla\Firefox\Profiles\*"
				"C:\Users\$ProfileName\AppData\Roaming\Microsoft\Signatures\*"
				"C:\Users\$ProfileName\AppData\Local\Packages\Microsoft.Office.OneNote_8wekyb3d8bbwe\*"
				"C:\Users\$ProfileName\AppData\Local\Microsoft\OneNote\16.0\Backup\*"
				"C:\Users\$ProfileName\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*"
				"C:\Users\$ProfileName\AppData\Local\Microsoft\Vault\*"
			)

			$DestinationPaths = @(
				"C:\Users\$NewProfileName\Desktop"
				"C:\Users\$NewProfileName\Downloads"
				"C:\Users\$NewProfileName\Documents"
				"C:\Users\$NewProfileName\Pictures"
				"C:\Users\$NewProfileName\Videos"
				"C:\Users\$NewProfileName\Appdata\Roaming\microsoft\windows\recent\automaticdestinations"
				"C:\Users\$NewProfileName\AppData\Local\Google\Chrome\User Data\Default"
				"C:\Users\$NewProfileName\AppData\Local\Microsoft\Edge\User Data\Default"
				"C:\Users\$NewProfileName\AppData\Roaming\Mozilla\Firefox\Profiles"
				"C:\Users\$NewProfileName\AppData\local\Mozilla\Firefox\Profiles"
				"C:\Users\$NewProfileName\AppData\Roaming\Microsoft\Signatures"
				"C:\Users\$NewProfileName\AppData\Local\Packages\Microsoft.Office.OneNote_8wekyb3d8bbwe"
				"C:\Users\$NewProfileName\AppData\Local\Microsoft\OneNote\16.0\Backup"
				"C:\Users\$NewProfileName\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
				"C:\Users\$NewProfileName\AppData\Local\Microsoft\Vault"
			)

			# Move-Item moves data into new profile programmatically 
			foreach ( $SourcePath in $SourcePaths ) {
				foreach ( $DestinationPath in $DestinationPaths ) {
					Move-Item -Path $SourcePath -Destination $DestinationPath
				}
			}

			# Move-Item moves data for outlook data files if the $True boolean value is passed in via the IncludeOutlookData parameter
			if ( $IncludeOutlookData -eq $True ) {
				Move-Item -Path "C:\Users\$ProfileName\AppData\Local\Microsoft\Outlook\*" -Destination "C:\Users\$NewProfileName\AppData\Local\Microsoft\Outlook"
			}

		} # End if statement

		else {
			Write-Warning "Error - File path C:\Users\$ProfileName or C:\Users\$NewProfileName doesn't exist!"
			Write-Warning "Re-run script after logging in with user credentials to create the new profile if it doesn't exist"
		}

	} # End process block

} # End function