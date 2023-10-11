function Get-TerminatedEmployee {
    
    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$ObjectId
    ) 
    process {

        $Attributes = Get-CASMailbox -Identity $UserPrincipalName
        $Mailbox = Get-Mailbox -Identity $UserPrincipalName 
        $Azure = Get-AzureADUser -ObjectId $ObjectId
        $Rules = Get-InboxRule -Mailbox $UserPrincipalName 

        $TerminatedEmployee = [Ordered]@{
        
            "Mailbox Disabled"             = $Mailbox.AccountDisabled
            "Azure Object Enabled"         = $Azure.AccountEnabled
            "Mailbox Hidden from GAL"      = $Mailbox.HiddenFromAddressListsEnabled
            "Litigation Hold Enabled"      = $Mailbox.LitigationHoldEnabled
            "Mailbox Forwarding"           = $(if ($null -eq $Mailbox.ForwardingSmtpAddress) {$False} else { $Mailbox.ForwardingSmtpAddress })
            "POP Protocol Enabled"         = $Attributes.PopEnabled
            "IMAP Protocol Enabled"        = $Attributes.ImapEnabled
            "MAPI Protocol Enabled"        = $Attributes.MAPIEnabled
            "OWA Protocol Enabled"         = $Attributes.OWAEnabled
            "Active Sync Enabled"          = $Attributes.ActiveSyncEnabled
            "Exchange Web Service Enabled" = $Attributes.EWSEnabled 
            "Mailbox Rules Removed"        = $(if ($null -eq $Rules) { $True })
        
        }
        
        Write-Output $TerminatedEmployee # Confirm user is created by outputting a custom ps object

    }



} # End function