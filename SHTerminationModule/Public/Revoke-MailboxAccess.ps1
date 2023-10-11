function Revoke-MailboxAccess {

    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName
    ) 
    process {
        # Disable mailbox access 
        Set-Mailbox -Identity $UserPrincipalName -AccountDisabled:$True
    }
}