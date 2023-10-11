function Set-MailboxAttribute {

    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName
    ) 
    process {
        # Disable email app protocols
        Set-CASMailbox -Identity $UserPrincipalName -PopEnabled $False
        Set-CASMailbox -Identity $UserPrincipalName -ImapEnabled $False
        Set-CASMailbox -Identity $UserPrincipalName -MAPIEnabled $False
        Set-CASMailbox -Identity $UserPrincipalName -OWAEnabled $False
        Set-CASMailbox -Identity $UserPrincipalName -ActiveSyncEnabled $False
        Set-CASMailbox -Identity $UserPrincipalName -EWSEnabled $False
    }
}