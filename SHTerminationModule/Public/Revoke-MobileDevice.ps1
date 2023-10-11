function Revoke-MobileDevice {
     
    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName
    ) 
    process {
        Get-MobileDevice -Mailbox $UserPrincipalName | ForEach-Object { 
            Remove-MobileDevice -Identity $_.Guid -Confirm:$false | Out-Null # Remove users mailbox from phone
        }        
    }   
}