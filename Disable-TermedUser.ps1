function Disable-TermedUser {

    <#

.SYNOPSIS
Fully disables a terminated user

.DESCRIPTION
Disables user object, creates a scambled password and resets password on account, moves user account to disabled user ou, removes all group memberships, runs delta sync to ensure office 365 account is disabled, clears any office 365/azure licenses, converts office 365 mailbox to a shared mailbox

.PARAMETER Identity
SamAccountName, UPN, GUID, or SID of a user account you want to disable

.EXAMPLE

Disable-TermedUser -Identity "Shane" -Email "Shane@smhcomputers.com"

.NOTES
Must be ran from a Domain Controller as either a user with domain administrator, local administrator, or server operator role

Must use an Office 365 account with proper permissions, and AD Sync needs to be installed

#>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $True)]
        [String]$Identity,

        [Parameter(ValueFromPipeline = $True)]
        [String]$Email


        # disabled users OU as parameter, UPN as parameter for username, credential to connect to O365
    )

    Import-Module ActiveDirectory

    $TermedUser = Get-ADUser -Identity $Identity; Disable-ADAccount $TermedUser

    Add-Type -AssemblyName System.Web # Add Assembly to use the Security.Membership classes 'GeneratePassword' method
    $RandomizedPassword = [System.Web.Security.Membership]::GeneratePassword(16, 4) # Create a 16 character password with 4 special characters
    
    [securestring]$securePassword = ConvertTo-SecureString $RandomizedPassword -AsPlainText -Force
    
    Set-ADAccountPassword -Identity $TermedUser -NewPassword $securePassword # Set a randomized password on terminated user account
    
    $Groups = Get-ADPrincipalGroupMembership -Identity $TermedUser | Where-Object name -ne "Domain Users" # Removing user from all groups excluding "Domain Users"
    ForEach ($Group in $Groups) {
        Remove-ADGroupMember -Identity $Group -Members $TermedUser -Confirm:$false
    }

    $DisabledOU = Get-ADOrganizationalUnit -LDAPFilter "(Name=*disabled*)" # Finding Disabled Users OU
    Move-ADObject -Identity $TermedUser -TargetPath $DisabledOU

    $ADSync = Get-Service -Name ADSync 

    if ($ADSync.Status -ne "Running") {
        Start-Service $AdSync
    }

    Start-ADSyncSyncCycle -PolicyType Delta # Sync change to Office 365 

    Write-Host "Please type Exchange Credentials in"
    Connect-ExchangeOnline
    Set-Mailbox -Identity $Email -Type Shared | Out-Null

    Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.ReadWrite.All" # Connect to Microsoft Graph API

    $MgUser = Get-mguser | Where-Object Mail -Match $Email
    $MgLicense = Get-MGUserLicenseDetail -UserId $MgUser.id | Select-Object -ExpandProperty SkuId
    
    if ($MgLicense) {
        # If MgLicense is not null, revoke licenses
        Set-MgUserLicense -UserId $MgUser.Id -AddLicenses @() -RemoveLicenses @($MgLicense) # Revoke license from account
    }

} # End Function