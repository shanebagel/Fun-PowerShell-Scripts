# PowerShell-Fun-Stuff
### List of scripts I've written by hand and used in production - work in progress

### Add users in an OU to a Group

>Script to Get all users in a particular OU in AD, and add those users based on SamAccountName property to a specified group

```
Get-ADUser -filter * -searchbase "OU=Users,OU=Lakeland,DC=aspirion,DC=com" | ForEach-Object {Add-AdGroupMember -Identity LAK_SP_ATU_READ -members $_.SamAccountName}
```

### Add users from a CSV to a Group

> Imports users from a comma separated list, uses a for loop to add those users to a specified group using Add-AdGroupMember 

```
$Groups = Import-CSV C:\Users\ecw_aspirion\users.csv 


$Groups |

ForEach-Object {

$Group = $_.Group 

Get-ADUser -SearchBase "OU=Users,OU=Lakeland,DC=aspirion,DC=com" -Filter * | ForEach-Object { 
Add-AdGroupMember -Identity $Group -Members $_}

}
```

### Add users from an "internal" CSV to a Group

>Adds users from a comma separated "internal" list. Doesn't rely on any external files, the delimiter is the new line splitting on (“`n”)

```
$GroupCsv = @"
GroupName1
GroupName2
GroupName3
GroupName4
"@

$UserOU = "OU=Users,OU=Lakeland,DC=aspirion,DC=com"

$Groups = $GroupCsv -split (“`n”)
$Users = Get-ADUser -SearchBase $UserOU -Filter *


ForEach ($Group in $Groups) {

Get-ADGroup $Group


    $Users | ForEach-Object {
        Add-ADGroupMember -Identity $Group -Members $_
    }


}
```

### Install Software from an EXE silently, no GUI
```
Start-Process -Wait -FilePath "PathToExe.exe" -ArgumentList "/S /v/qn" -PassThru
```

### Bulk Create AD Distribution Groups from CSV
```
Import-Module ActiveDirectory
$Users = Import-CSV 'C:\Users\ecw\Desktop\DL.csv'

ForEach ($User in $Users){

$groupProperties = @{

Name = $User.Name
DisplayName = $User.Name
Path = "OU=Distribution Groups,OU=ParkShore,DC=main,DC=parkshoredrug,DC=com"
SamAccountName = $User.Name
GroupScope = "Universal"
GroupCategory = "Distribution"

}

New-ADGroup @groupProperties

}
```

### Bulk Update AD User/Group Attributes from CSV
```
Import-Module ActiveDirectory
$Users = Import-CSV 'C:\Users\ecw\Desktop\DL.csv'

ForEach ($User in $Users){

$groupAttributes = @{

Identity = $user.Name
Replace = @{Mail=$user.Email}


}

Set-ADGroup @groupAttributes

}
```

### Bulk update Primary Proxy Addresses from CSV
```
Import-Module ActiveDirectory
$users = Import-CSV "C:\Users\ecw\desktop\myfile.csv" 
$users | foreach {Set-ADUser -Identity $_.samaccountname -add @{Proxyaddresses= "SMTP:" + $_.Proxyaddresses -split ","}}
# Column names are samAccountName and Proxyaddresses in the CSV file
```

### Bulk update Passwords on New User Accounts from CSV 
```
$users = Import-Csv C:\Users\ecw\desktop\users.csv
$SecurePass = Read-Host "Enter Password" -AsSecureString

$users | ForEach {Set-ADAccountPassword -Identity $_.SamAccountName -NewPassword $SecurePass}

Start-ADSyncSyncCycle -PolicyType Delta
```

### Bulk retrieve Group Membership for all Disto Lists in an OU

```
$Groups = Get-ADGroup -SearchBase "OU=Distribution Groups,OU=ParkShore,DC=main,DC=parkshoredrug,DC=com" -Filter * | Select-Object Name

$results = Foreach ($Group in $Groups) {
Get-ADGroupMember $Group | Select-Object Name, @{n='GroupName';e={$Group.Name}}
}

$Groups | Out-File C:\Users\ecw\desktop\Groups.txt
```

### Clear-DriveSpace - Clears out unused drive space on a windows system

```
<#
.SYNOPSIS
Clear-DriveSpace takes a computer name and runs through a set of processes that clears out unused drive space on a local computer.

.DESCRIPTION
Clear-DriveSpace is a tool that can be run on systems with low drive space. It uses TreeSize after the program is finished executing to display the remaining drive space and what is using up most of it. The tool can only be run on systems where a GUI is installed, due to TreeSize requiring a GUI to view what is utilizing drive space, allowing the user to manually remove remaining files.

.PARAMETER ComputerName
ComputerName is a required parameter for this script. You can type localhost to run it on the current system or the current hostname.

.EXAMPLE
Clear-DriveSpace -ComputerName "Shanelaptop"

.NOTES 
Must be run as an administrator.
Must be running at least PowerShell Version 5.0 - check with $PSVersionTable.
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [String]$ComputerName
)

Write-Host "Thanks for running my cleanup utility! Let's begin cleaning up disk space."  -ForeGroundColor Black -BackGroundcolor White

# For loop runs through all computer names, downloads drive cleanup utilities, removes temp files, runs Wicleanup proces
if (Test-Connection $ComputerName -Quiet) {

    # Remove temp contents - Recursively delete
    $Temp = 'C:\Temp'
    if (Test-Path -Path $Temp) {
        Set-Location $Temp
        Get-ChildItem * | Remove-Item -Recurse -Force
        Write-Host "Setting location to Temp directory and clearing all temp files." -ForeGroundColor Black -BackGroundcolor White
        Start-Sleep 3
    }
    else {
        Start-Sleep 3
        Write-Host "Error: Temp directory doesn't exist." -ForeGroundColor Black -BackGroundcolor Yellow
    }

    # Remove least cumulative updates contents - Recursively delete
    $Lcu = 'C:\Windows\servicing\lcu'
    if (Test-Path -Path $Lcu) {
        Set-Location $Lcu
        Get-ChildItem * | Remove-Item -Recurse -Force
        Write-Host "Setting location to last cumulative update directory and clearing all temp update files." -ForeGroundColor Black -BackGroundcolor White
        Start-Sleep 3
    }
    else {
        Start-Sleep 3
        Write-Host "Error: Lcu directory doesn't exist." -ForeGroundColor Black -BackGroundcolor Yellow
    }

    # Remove Software Distribution contents - Recursively delete
    $Swdistro = 'C:\Windows\SoftwareDistribution'
    if (Test-Path -Path $Swdistro) {
        Set-Location $Swdistro
        Get-ChildItem * | Remove-Item -Recurse -Force
        Write-Host "Setting location to Windows Temp update directory and clearing all temp update files." -ForeGroundColor Black -BackGroundcolor White
        Start-Sleep 3
    }
    else {
        Start-Sleep 3
        Write-Host "Error: Software Distribution directory doesn't exist." -ForeGroundColor Black -BackGroundcolor Yellow
    }

    # Remove Recycle Bin contents - Recursively delete
    $Recycle = 'C:\$RECYCLE.BIN'
    if (Test-Path -Path $Recycle) {
        Set-Location $Recycle
        Get-ChildItem * | Remove-Item -Recurse -Force
        Write-Host "Setting location to Recycle Bin directory and permanently removing deleted items." -ForeGroundColor Black -BackGroundcolor White
        Start-Sleep 3
    }
    else {
        Start-Sleep 3
        Write-Host "Error: Recycle Bin not enabled." -ForeGroundColor Black -BackGroundcolor Yellow
    }

    Write-Host "Downloading drive cleanup utilities." -ForeGroundColor Black -BackGroundcolor White

    # Download Treesize
    $treesize = 'http://www.jam-software.com/treesize_free/TreeSizeFreeSetup.exe' 
    $path = "C:\Temp\treesize.exe"
    Start-BitsTransfer -Source $treesize -Destination $path

    # Download Wicleanup
    $wicleanupc = "https://fm.solewe.com/vfm-admin/vfm-downloader.php?q=0&sh=98b0a30e8e36652bab02f90771e8128a&share=8564959590d7c06333f81e5b7ee18fc2"
    $path = "C:\Temp\wicleanup.7z"
    Start-BitsTransfer -Source $wicleanupc -Destination $path

    # Install 7Zip module to extract Wicleanup
    Install-Module -Name 7Zip4PowerShell -Force
    $wicleanupzip = "C:\Temp\wicleanup.7z"
    Expand-7Zip -ArchiveFileName $wicleanupzip -TargetPath 'C:\Temp\wicleanup'

    Write-Host "Running Wicleanup process - Removing all unused MSP/MSI files - Click OK when complete" -ForeGroundColor Black -BackGroundcolor White
    Set-Location $Temp'\wicleanup'
    .\WICleanupC.EXE -s | Out-Null # Running Wicleanup and piping output to Out-Null so PWSH waits until the process finishes
       
    Write-Host "Running disk cleanup utility." -ForeGroundColor Black -BackGroundcolor White
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/verylowdisk" -Wait
        
    Write-Host "Starting 'Programs and Features menu' - Please manually remove unused programs." -ForeGroundColor Black -BackGroundcolor White
    Start-Process -FilePath "appwiz.cpl" | Out-Null
        
    Write-Host "Starting 'TreeSize' - Please finish exe installation and examine what is consuming remaining drive space." -ForeGroundColor Black -BackGroundcolor White
    Set-Location "C:\Temp"
    .\treesize.exe 
       
}
else {
    Start-Sleep 3
    Write-Warning "Error: Cannot connect to $ComputerName. Please verify computer name and network connectivity."  -ForeGroundColor Yellow -BackGroundcolor Black
}

```
