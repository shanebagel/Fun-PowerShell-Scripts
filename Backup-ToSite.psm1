function Backup-ToSPSite {

    <#
.SYNOPSIS
Migrates on-premise file share data to an Office 365 SharePoint site using the SharePoint Online Management Shell

.DESCRIPTION
Backup-ToSPSite can be ran against remote or local systems. It uses the SharePoint online Migration tool. The tool will connect to an Office 365 tenant, and create the site before the migration executes. A migration job will be created after a new site is created, and data will be copied to the defined SharePoint site

.PARAMETER Credential
Password of the Office 365 account provided. PSCredential will initially prompt for credentials used for migration job. Get-Credential will prompt once, then you will also be prompted when initially connecting to the tenant 

.PARAMETER Directory
Location of the local file share you wish to backup to SharePoint. Defaults to present working directory that script is ran from

.PARAMETER ComputerName
Name of the server you are running the migration job on. Can be localhost or hostname of system. Defaults to localhost

.PARAMETER SiteName
The name of the new SharePoint site. Example: https://mycompany.sharepoint.com/sites/SPSite - 'SPSite' would be the site name. Defaults to new site

.PARAMETER Domain
The name of the domain that the SharePoint tenant uses. Example: https://mycompany.sharepoint.com - 'mycompany' would be the Domain name - exclude top level domain, ex: .com

.PARAMETER Owner
Owner of the new SharePoint site. Defaults to the username of the account that's passed in 

.PARAMETER Template
Template for the SharePoint site - Accepted templates are team sites, communication sites, project sites, document center sites, and community sites
Accepted inputs: STS#3 (team site), STS#0 (team site classic), SITEPAGEPUBLISHING#0 (communication site), PROJECTSITE#0 (project site), BDR#0 (document center site), COMMUNITY#0 (community site). 
Defaults to team site

.EXAMPLE
Run from the present working directory with all defaults
Backup-ToSPSite -Domain "PizzaHut"

.EXAMPLE
Defining all arguments
Backup-ToSPSite -Directory "C:\Users\Shane\MyPizzas" -ComputerName "Shanelaptop" -SiteName "ShanesPizzas" -Domain "PizzaHut" -Owner "shane@pizzahut.com" -Template "STS#3"

.NOTES
Must be ran as administrator

Prerequisite: Installation of the SharePoint Migration Tool - as it cannot be automated
https://spmt.sharepointonline.com/spmtinstaller/spmtbuild/publicpreview/spmtsetup_beta.exe

Owner permission by default, is set to the mailbox you pass in the credentials for

MFA for the office 365 account has to be disabled
Account you use to authenticate has to have either the SharePoint administrator or Global administrator role
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNull()]
        [pscredential]$Credential,

        [Parameter(Mandatory = $False)]
        [String]$Directory = $pwd.Path,

        [Parameter(Mandatory = $False)]
        [String]$ComputerName = "localhost",

        [Parameter(Mandatory = $False)]
        [String]$SiteName = "New Site",

        [Parameter(Mandatory = $True)]
        [String]$Domain,

        [Parameter(Mandatory = $False)]
        [String]$Owner = $Credential.UserName,

        [Parameter(Mandatory = $False)]
        [ValidateSet("STS#3", "STS#0", "SITEPAGEPUBLISHING#0", "PROJECTSITE#0", "BDR#0", "COMMUNITY#0")]
        [String]$Template = "STS#3"
    )

    # Root and Site SharePoint Url strings:
    $RootAdminUrl = "https://$Domain-admin.sharepoint.com/"
    $SiteUrl = "https://$Domain.sharepoint.com/sites/$SiteName"

    if (-not(Test-Connection -ComputerName $ComputerName -Quiet)) {
        Write-Warning "Error: Cannot connect to $ComputerName - Please verify network connectivity"
        break # Stop executing
    }

    $PathExists = Test-Path $Directory # Check if directory passed into Directory parameter exists - if not, script stops executing
    if ($PathExists -eq $False) {
        Write-Warning "Error: $Directory is not a valid File Path - Please run again with a valid File Path" 
        break # Stop executing 
    }

    Write-Information "Installing SharePoint PowerShell Module"
    $SPModule = 'Microsoft.Online.SharePoint.PowerShell'
    Install-Module -Name $SPModule -Force
    Import-Module Microsoft.Online.SharePoint.PowerShell

    Write-Information "Installing SharePoint MigrationTool PowerShell Module"
    Set-Location $env:UserProfile\Documents\WindowsPowerShell\Modules\Microsoft.SharePoint.MigrationTool.PowerShell
    $SPMTModule = 'Microsoft.SharePoint.MigrationTool.PowerShell'
    Import-Module $SPMTModule

    # $SPOCredential = New-Object -Type System.Management.Automation.PSCredential -Argumentlist $Credential
    Write-Host "Connecting to Tenant: Please enter your Office 365 Global Administrator credentials" -ForeGroundColor Black -BackGroundcolor Yellow
    Connect-SPOService -Url $RootAdminUrl

    # Add functionality to be able to get a list of templates using Get-SPOWebTemplate and be able to pass in a template as a parameter

    Invoke-Command -ScriptBlock { New-SPOSite -Url $SiteUrl -Owner $Owner -StorageQuota 1000 -Title $SiteName -Template $Template } # Create a new site

    $Global:SPOUrl = $SiteUrl
    $Global:UserName = $Credential.username
    $Global:Password = $Credential.password
    $Global:TargetListName = "Documents"
    $Global:SPOCredential = New-Object -Type System.Management.Automation.PSCredential -ArgumentList $Global:UserName, $Global:Password

    Import-Module Microsoft.SharePoint.MigrationTool.PowerShell # Installation of SPMT installs the PS MigrationTool module
    Register-SPMTMigration -SPOCredential $Global:SPOCredential -Force

    # Defining Data source

    $Global:FileShareSource = $Directory 

    Add-SPMTTask -FileShareSource $Global:FileShareSource -TargetSiteUrl $Global:SPOUrl -TargetList $Global:TargetListName

    Start-SPMTMigration

    Write-Host "SharePoint Site Created - Migration Complete" -ForeGroundColor Black -BackGroundcolor Yellow
    Get-SPOSite | Where-Object { $_.Url -eq $SiteUrl } | Select-Object Title, Status, Url

} # End of function