function Move-ProfileData { # Start function

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

.PARAMETER ComputerName
Computer name of the machine that houses the profile data. Defaults to local hostname where script is ran from

.PARAMETER NewProfileName
New profile you're migrating data into

.PARAMETER OldProfileName
Old profile you're migrating data out of 

.PARAMETER IncludeOutlookData
If $true is passed in outlook data files will be copied over to new profile. By default outlook data files will not be included in move

.EXAMPLE
Move-ProfileData -ComputerName "Shaneserver" -OldProfileName "oldprofile" -NewProfileName "newprofile" -IncludeOutlookData $False

.NOTES
Can be ran after Start-ProfileRebuild.ps1

#>

	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline = $True, Mandatory = $False)]
		[String]$ComputerName = $env:COMPUTERNAME,

		[Parameter(Mandatory = $True)]
		[String]$NewProfileName,

		[Parameter(Mandatory = $True)]
		[String]$OldProfileName,

		[Parameter(Mandatory = $True)]
		[Boolean]$IncludeOutlookData

	) 

	begin {
		$SourceProfileExists = Test-Path "C:\Users\$OldProfileName"
		$DestinationProfileExists = Test-Path "C:\Users\$NewProfileName"
		$TestCondition = (($SourceProfileExists) -and ($DestinationProfileExists))	
	}

	process {

		if ( $TestCondition ) {

			$SourcePaths = @( # Source file locations
				"C:\Users\$OldProfileName\Desktop\*"
				"C:\Users\$OldProfileName\Downloads\*"
				"C:\Users\$OldProfileName\Documents\*"
				"C:\Users\$OldProfileName\Pictures\*"
				"C:\Users\$OldProfileName\Videos\*"
				"C:\Users\$OldProfileName\Appdata\Roaming\microsoft\windows\recent\automaticdestinations\*"
				"C:\Users\$OldProfileName\AppData\Local\Google\Chrome\User Data\Default\*"
				"C:\Users\$OldProfileName\AppData\Local\Microsoft\Edge\User Data\Default\*"
				"C:\Users\$OldProfileName\AppData\Roaming\Mozilla\Firefox\Profiles\*"
				"C:\Users\$OldProfileName\AppData\local\Mozilla\Firefox\Profiles\*"
				"C:\Users\$OldProfileName\AppData\Roaming\Microsoft\Signatures\*"
				"C:\Users\$OldProfileName\AppData\Local\Packages\Microsoft.Office.OneNote_8wekyb3d8bbwe\*"
				"C:\Users\$OldProfileName\AppData\Local\Microsoft\OneNote\16.0\Backup\*"
				"C:\Users\$OldProfileName\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*"
				"C:\Users\$OldProfileName\AppData\Local\Microsoft\Vault\*"
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
			for ($i = 0; $i -lt $SourcePaths.Length; $i++) {
				$SourcePath = $SourcePaths[$i]
				$DestinationPath = $DestinationPaths[$i]
				if ((Test-Path -Path $SourcePath) -and (Test-Path -Path $DestinationPath)) {
					Move-Item -Path $SourcePath -Destination $DestinationPath -Force # Move all content in directory to new profile directory
				}
				else {
					Write-Warning "Skipping directory $SourcePath as source or destination directory doesn't exist" 
				}
			} # End for loop
				
		} # End if statement

		elseif ( $TestCondition = $False ) {
			
			if ( $SourceProfileExists -eq $False ) {
				Write-Warning "Error - Source profile path C:\Users\$OldProfileName doesn't exist"
				Write-Warning "Double check the source profile name"
			}
			if ( $DestinationProfileExists -eq $False ) {
				Write-Warning "Error - Destination profile path C:\Users\$NewProfileName doesn't exist"
				Write-Warning "Re-run script after logging in with user credentials to create the new profile if it doesn't exist"
			}

		} # End elseif
				
		# Move-Item moves data for outlook data files if the $True boolean value is passed in via the IncludeOutlookData parameter
		if ( $IncludeOutlookData -eq $True ) {
			$OutlookSource = "C:\Users\$OldProfileName\AppData\Local\Microsoft\Outlook\*"
			$OutlookDestination = "C:\Users\$NewProfileName\AppData\Local\Microsoft\Outlook"

			$OutlookSourceExists = Test-Path -Path $OutlookSource
			$OutlookDestinationExists = Test-Path -Path $OutlookDestination

			if (($OutlookSourceExists) -and ($OutlookDestinationExists)) {
				Move-Item -Path "C:\Users\$OldProfileName\AppData\Local\Microsoft\Outlook\*" -Destination "C:\Users\$NewProfileName\AppData\Local\Microsoft\Outlook" -Force
			}
			else {
				Write-Warning "Directory skipped - Outlook OST source file path $OutlookSource or destination file path $OutlookDestination doesn't exist"
			}

		} # End if statement
	
	} # End process block
	
}  # End function