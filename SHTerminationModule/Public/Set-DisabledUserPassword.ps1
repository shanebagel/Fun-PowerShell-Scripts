function Set-DisabledUserPassword {

    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$ObjectId
    ) 

    process {
        # Setting a password on terminated account
        Add-Type -AssemblyName System.Web # Add type for secure password 
        $RandomizedPassword = [System.Web.Security.Membership]::GeneratePassword(15, 5) # Use GeneratePassword method on Security.Membership type to create a secure password
        $Cred = ConvertTo-SecureString -String $RandomizedPassword -AsPlainText -Force
        Set-AzureADUserPassword -ObjectId $ObjectId -Password $Cred # Set secure password value
    }

}