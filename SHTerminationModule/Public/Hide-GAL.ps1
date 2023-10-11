function Hide-GAL { 

    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName
    ) 
    process {
        # Hide mailbox from Global Address list
        Set-Mailbox -Identity $UserPrincipalName -HiddenFromAddressListsEnabled $True
    }
}