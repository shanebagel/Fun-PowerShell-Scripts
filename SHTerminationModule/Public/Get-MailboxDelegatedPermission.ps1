function Get-MailboxDelegatedPermission {

    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName
    ) 
    
    process {
        # List all mailboxes to which a particular user has Full Access permissions:
        Get-Mailbox -resultsize unlimited | Get-MailboxPermission -User $UserPrincipalName
        # List all mailboxes to which a user has Send As permissions:
        Get-Mailbox -resultsize unlimited | Get-RecipientPermission -Trustee $UserPrincipalName
        # List all mailboxes to which a particular security principal has Send on Behalf of permissions:
        Get-Mailbox -resultsize unlimited | Where-Object { $_.GrantSendOnBehalfTo -like $UserPrincipalName }
        # Other one-liners in case they are not included in the Full Access Permissions by default:
        Get-Mailbox -RecipientTypeDetails TeamMailbox -ResultSize:Unlimited | Get-MailboxPermission | Select-Object identity, user, accessrights | Where-Object { ($_.User -like $UserPrincipalName) }
        Get-Mailbox -RecipientTypeDetails DiscoveryMailbox -ResultSize:Unlimited | Get-MailboxPermission | Select-Object identity, user, accessrights | Where-Object { ($_.User -like $UserPrincipalName) }
        Get-Mailbox -RecipientTypeDetails EquipmentMailbox -ResultSize:Unlimited | Get-MailboxPermission | Select-Object identity, user, accessrights | Where-Object { ($_.User -like $UserPrincipalName) }
        Get-Mailbox -RecipientTypeDetails LegacyMailbox -ResultSize:Unlimited | Get-MailboxPermission | Select-Object identity, user, accessrights | Where-Object { ($_.User -like $UserPrincipalName) }
        Get-Mailbox -RecipientTypeDetails RoomMailbox -ResultSize:Unlimited | Get-MailboxPermission | Select-Object identity, user, accessrights | Where-Object { ($_.User -like $UserPrincipalName) }
        Get-Mailbox -RecipientTypeDetails SchedulingMailbox -ResultSize:Unlimited | Get-MailboxPermission | Select-Object identity, user, accessrights | Where-Object { ($_.User -like $UserPrincipalName) }
    }
}