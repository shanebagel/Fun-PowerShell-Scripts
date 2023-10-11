function Set-DisabledUserAttribute {   
  
        Param (
                [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
                [String]$ObjectId
        ) 

        process {
                # Updated attributes on account
                $DisplayName = Get-AzureADUser -ObjectId $ObjectId | Select-Object -ExpandProperty DisplayName 
                Remove-AzureADUserManager -ObjectId $ObjectId # Remove manager attribute
                Set-AzureADUser -ObjectId $ObjectId -CompanyName "Terminated" # Update Company Name attribute
                Set-AzureADUser -ObjectId $ObjectId -DisplayName "$DisplayName - Terminated" # Append Terminated attribute on display name
                Remove-AzureADUserExtension -ObjectId $ObjectId -ExtensionName 'TelephoneNumber' # Clear telephone number
                Remove-AzureADUserExtension -ObjectId $ObjectId -ExtensionName 'Mobile' # Clear mobile number      
        }
}