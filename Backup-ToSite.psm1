function Backup-ToSPSite {

    <#
.SYNOPSIS
Migrates on-premise file share data to an Office 365 SharePoint site using the SharePoint Online Management Shell

.DESCRIPTION
Backup-ToSPSite can be ran against remote or local systems. It downloads and executes the SharePoint migration tool. The tool will connect to an Office 365 tenant, and create the site before the migration continues. A migration job will be created after the site is created, and data will be copied to the defined SharePoint site

.PARAMETER Credential
Password credential to the Office 365 account provided

.PARAMETER Directory
Location of the directory you wish to backup to SharePoint

.PARAMETER ComputerName
Name of the server you are running the migration against. Can be localhost or the hostname of a remote system

.PARAMETER SiteName
Provide a name for for the new SharePoint site

.PARAMETER Permissions
Set permissions for users

.PARAMETER SiteURL
The root of the SharePoint tenant

.EXAMPLE
Backup-ToSite -ComputerName "Shaneserver" -Email 'shane@smhcomputers.com' -SiteName 'ShaneSP' -Directory 'C:\MyDirectory' -SiteURL 'https://hartleyshaneoutlook-admin.sharepoint.com'

.NOTES
Must be ran using O365 account with SharePoint Administrator and Global Administrator roles
Prerequisites are installing the PS SharePoint Online Management Shell
Must run the SharePoint Online Management Shell as administrator 
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNull()]
        [pscredential]$Credential,

        [Parameter(Mandatory = $True)]
        [String]$SiteURL,

        [Parameter(Mandatory = $True)]
        [String]$SiteName,

        [Parameter]
        [String]$ComputerName,

        [Parameter]
        [String]$Directory,

        [Parameter]
        [String]$Permissions

    )

    Install-Module –Name Microsoft.Online.SharePoint.PowerShell -Force # Install SPMT Module for SharePoint management

    $ProgressPreference = 'SilentlyContinue'
    $SPMT = 'https://spmt.sharepointonline.com/spmtinstaller/spmtbuild/publicpreview/spmtsetup_beta.exe'; 
    $Path = 'C:\Temp\'
    $SPMTEXE = "C:\Temp\SPMT.exe"
    if (Test-Path -Path $Path) {
        Invoke-WebRequest -Uri $SPMT -OutFile $SPMTEXE -UseBasicParsing
    } else {
        New-Item -Type Directory -Path C:\Temp -Name 'Temp'
        Invoke-WebRequest -Uri $SPMT -OutFile $SPMTEXE -UseBasicParsing
    }

$Credential = Get-Credential

$SPOCredential = New-Object -Type System.Management.Automation.PSCredential -Argumentlist $Credential

Connect-SPOService -Url $SiteURL -Credential $SPOCredential

} # End of function