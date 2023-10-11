function Start-TerminationProcess { # CONTROLLER SCRIPT

    <#
.SYNOPSIS
Terminates a user account in Office 365 

.DESCRIPTION
Terminates an employees Office 365 / Azure object

Confirms request was approved by HR
Prompts script runner to verify that user account doesn't exist in other tenants
Removes user's inbox rules
Blocks mobile devices from accessing mailbox
Wipes all mobile device data
Removes all mailbox access attributes (Exchange web services, IMAP, POP3, OWA, etc)
Hides mailbox from GAL (Global Address list)
Clears manager field on account
Signs user out of all active sessions
Sets a random 15 character password on mailbox
Blocks sign in on mailbox
Sets email forwarding 
Updates Company Name attribute to "Terminated" on account
Appends " - Terminated" to the Display Name attribute on account
Removes all groups from user account that are not dynamic groups
Removes phone number on account
Revokes MFA sessions
Require re-registration of MFA on account 
Removes all Azure RBAC roles from account
Checks if account has a litigation hold 
Prompts to regresses O365 Licensing to a level that maintains Exchange and OneDrive data 
Removes delegated access / send on behalf and full access permissions on other mailboxes
Prompts to send an email to SP administrator to remove access to SP
Prompts to send an email to all IT members to remove any email drafts with user credentials

.PARAMETER UserPrincipalName 
UPN of the user account you're terminating

This is the UPN in Azure / Office 365

.PARAMETER ForwardingAddress
Mailbox you want to forward emails to

.EXAMPLE
Place SHTerminationModule in a directory located in the $env:psmodulepath variable
Import-Module SHTerminationModule
Get-Command -Module SHTerminationModule
$UPN = 'FirstName.LastName@honuservices.com'
Start-TerminationProcess -UserPrincipalName $UPN

.NOTES
Must be ran from at least PowerShell version 7.x 

Requires modules "AzureAD", "ExchangeOnlineManagement" be installed

Module folder must be placed in a directory in $Env:PSModulePath
#>

    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [String]$ForwardingAddress
    ) 

    begin {
        # Importing modules - AzureAD, and ExchangeOnlineManagement Modules must be installed
        $Modules = "AzureAD", "ExchangeOnlineManagement", "SHTerminationModule"
        Import-Module $Modules
        Connect-ExchangeOnline
        Connect-AzureAD
    }

    process {

        # Add -verbose - and remove anything from tools that outputs to the pipeline, all you want back is success or failure 
        # Tool should be ran with -Verbose if the user wants output

        Confirm-TerminationInformation
        $ObjectId = Get-AADObjectId -UserPrincipalName $UserPrincipalName
        Remove-MailboxRule -UserPrincipalName $UserPrincipalName
        Revoke-MobileDevice -UserPrincipalName $UserPrincipalName
        Hide-GAL -UserPrincipalName $UserPrincipalName
        Revoke-MailboxAccess -UserPrincipalName $UserPrincipalName
        Set-MailboxAttribute -UserPrincipalName $UserPrincipalName
        Set-DisabledUserAttribute -ObjectId $ObjectId
        Disable-AADObject -ObjectId $ObjectId
        Set-DisabledUserPassword -ObjectId $ObjectId

        if ($ForwardingAddress) {
            # If forwarding is passed in 
            Set-MailboxForwarding -UserPrincipalName $UserPrincipalName -ForwardingAddress $ForwardingAddress
        }

        Get-TerminatedEmployee -UserPrincipalName $UserPrincipalName -ObjectId $ObjectId

    } # End Process bloock

    end {

        # Warnings:
        Write-Warning -Message "Manually regress O365 Licensing to a level that maintains Exchange and OneDrive data" # Remove-License
        Write-Warning -Message "Manually remove any Azure classic or Azure RBAC roles" # Remove-RBAC and Classic roles
        Write-Warning -Message "Manually remove Adobe licenses assigned to user" # Can't automate
        Write-Warning -Message "Send an email to SP administrator to remove access to SP - See email template" # Reminder
        Write-Warning -Message "Send an email to all IT members to remove any email drafts with user credentials - See email template" # Reminder
        Write-Warning -Message "Starting long-running mailbox script to retrieve terminated users delegated mailbox permissions" # Runs at the end of controller script
        Get-MailboxDelegatedPermission -UserPrincipalName $UserPrincipalName 

    } # End block

} # End function