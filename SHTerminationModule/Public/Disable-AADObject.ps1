function Disable-AADObject {

    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$ObjectId
    ) 
    process {
        # Disables AAD Object
        $ObjectId | Revoke-AzureADUserAllRefreshToken # Revoke MFA sessions and any active sessions
        Set-AzureADUser -ObjectId $ObjectId -AccountEnabled $False # Disables account
    }
}