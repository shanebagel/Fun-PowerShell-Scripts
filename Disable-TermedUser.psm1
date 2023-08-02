function Disable-TermedUser {


# In-progress



    <#
.SYNOPSIS
Fully disables a terminated user

.DESCRIPTION
Disables user object, creates a scambled password and resets password on account, moves user account to disabled user ou, removes all group memberships, runs delta sync to ensure office 365 account is disabled, clears any office 365/azure licenses, converts office 365 mailbox to a shared mailbox, hides shared mailbox from Global Address List (GAL)

.PARAMETER Identity
SamAccountName, UPN, GUID, or SID of a user account you want to disable

.EXAMPLE

.NOTES
Must be ran from a Domain Controller as either a user with domain administrator, local administrator, or server operator role

#>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $True)]
        [value]$Identity,

        [Parameter(ValueFromPipeline = $True)]
        [value]$Param2


        # disabled users OU as parameter, UPN as parameter for username, credential to connect to O365
    )


    Install-Module ActiveDirectory -Wait
    Import-Module ActiveDirectory

    $TermedUser = Get-ADUser -Identity $Identity | Disable-ADAccount

    Add-Type -AssemblyName System.Web # Add Assembly to use the Security.Membership classes 'GeneratePassword' method
    $RandomizedPassword = [System.Web.Security.Membership]::GeneratePassword(16,4) # Create a 16 character password with 4 special characters
    $userName = $TermedUser.SamAccountName
    
    [securestring]$securePassword = ConvertTo-SecureString $RandomizedPassword -AsPlainText -Force
    [pscredential]$secureCredential = New-Object System.Management.Automation.PSCredential ($userName, $securePassword)
    
    Set-ADUser -Identity $userName -Credential $secureCredential # Set a randomized password on user account
    
    Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.ReadWrite.All" # Connect to Microsoft Graph API


    # Steps
    # Disables user object - Done
    # creates a scambled password and resets password on account
    # clears any office 365/azure licenses
    # Remove all group memberships
    # moves user account to disabled user ou
    # runs delta sync to ensure office 365 account is disabled
    # converts office 365 account to a shared mailbox
    # hides shared mailbox from Global Address List (GAL)

}