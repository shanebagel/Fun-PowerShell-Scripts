Function Set-ClearanceAttribute {

    <#
.SYNOPSIS
Sets clearance attribute on user object in Azure

.DESCRIPTION
Sets the clearance attribute on account - uses boolean value for Clearance Status

.PARAMETER UserPrincipalName
UPN of the Azure account you're setting the clearance attribute value on

.PARAMETER ClearedStatus
Clearance status

CLEARED = Employee has been cleared
UNCLEARED = Employee does not have a clearance 

.EXAMPLE
Set cleared attribute to true on account
Set-ClearedAttribute -UserPrincipalName "Bob@Builders.com" -ClearedStatus $True 

#>

    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$UserPrincipalName,

        [Parameter(Mandatory = $True)]
        [ValidateSet("CLEARED", "UNCLEARED")]
        [String]$ClearedStatus
    ) 

    begin {
        Import-Module AzureAD
        Connect-AzureAD 
    }

    process {
        $user = Get-AzureADUser -Filter "Mail eq '$UserPrincipalName'"
        Set-AzureADUserExtension -ObjectId $user.ObjectId -ExtensionName "extension_719260cce49c48868cc9164101bece47_GovSecStatus" -ExtensionValue "$ClearedStatus"
    }

} # End functions
