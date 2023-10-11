function Remove-MailboxRule {
    
    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName
    ) 
    process {
        Get-InboxRule -Mailbox $UserPrincipalName | Remove-InboxRule -Confirm:$false # Remove inbox rules from mailbox    
    }
}