function Set-MailboxForwarding {
    
    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$ForwardingAddress    
    ) 
    
    process {
        Set-Mailbox -Identity $UserPrincipalName -ForwardingSmtpAddress "smtp:$ForwardingAddress"    
    }
}