function Get-AADObjectId {
    
    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName
    ) 

    process {
        $Object = (Get-AzureADUser -ObjectId $UserPrincipalName) # Get object ID

        if ($Object.DirSyncEnabled -eq $True) {
            Write-Warning -Message "On-Premise directory sync enabled - Make changes from Organizations Domain Controller"
            break
    }
    return $Object.ObjectId
}

} # End functions