function New-UserHire {

    <#
    .SYNOPSIS
    Fully creates a new user account

    .DESCRIPTION
    Creates a new user account, sets a secure password for the account, adds proxy addresses to on-premise account,
    add user to relevant groups, runs a delta sync, licenses out office 365 mailbox

    .PARAMETER Credential
    Credential for new user. Set a password as a secure string. You can either set a password automatically without running the function with -Credential - it will automatically prompt you, or you can create a secure string object first and pass it in

    .PARAMETER FirstNameDotLastNameConvention
    Pass in either $true or $false if the username is first.last - Example: Bob Builder -> bob.builder

    .PARAMETER FirstInitialLastNameConvention
    Pass in either $true or $false if the username is flast - Example: Bob Builder -> bbuilder

    .PARAMETER EmailAddress
    Email address of the employee - if you don't include a primary domain - the email will default to the on-premise UPN of the new user - which is SamAccountName@Domain.com

    .PARAMETER License
    License for the new user. Can be any of the following values:

    Basic, Standard, Premium, ExoPlan1, ExoPlan2, Enterprise1, Enterprise3, Enterprise5

    Sku ID: 3b555118-da6a-4418-894f-7df1e2096870 # Business Basic - O365_BUSINESS_ESSENTIALS 
    Sku ID: f245ecc8-75af-4f8e-b61f-27d8114de5f3 # Business Standard - O365_BUSINESS_PREMIUM
    Sku ID: cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46 # Business Premium - SPB
    Sku ID: 4b9405b0-7788-4568-add1-99614e613b69 # Exchange Online (Plan 1) - EXCHANGESTANDARD
    Sku ID: 19ec0d23-8335-4cbd-94ac-6050e30712fa # Exchange Online (PLAN 2) - EXCHANGEENTERPRISE
    Sku ID: 18181a46-0d4e-45cd-891e-60aabd171b4e # Enterprise 1 - STANDARDPACK
    Sku ID: 6fd2c87f-b296-42f0-b197-1e91e994b900 # Enterprise 3 - ENTERPRISEPACK
    Sku ID: c7df2760-2c81-4ef7-b578-5b5392b571df # Enterprise 5 - ENTERPRISEPREMIUM

    .PARAMETER PrimaryDomain
    Primary domain of the employee. Will default to using the on-premise domain if you don't specify a domain name
    
    .PARAMETER ProxyDomain
    Proxy address of the employee - if you don't include a domain, no proxy address will be included and email will match on-premise UPN.
    Example bobsbuilders.com is the proxy domain - the email would end up being bob.builder@bobsbuilders.com 

    .PARAMETER FirstName
    First name of the new user

    .PARAMETER LastName
    Last name of the new user 
    
    .PARAMETER Path 
    Distinguished name attribute of the OU where you want the user account to be created in. 
    
    .PARAMETER OfficePhone
    Office phone number for the new user

    .PARAMETER Description
    Description for the new user object

    .PARAMETER Groups
    Security or Distribution groups to add the user to

    .PARAMETER CannotChangePassword 
    Set to either $true or $false - Used by New-ADUser to determine if the user is allowed to change their own account password

    .PARAMETER ChangePasswordAtLogon 
    Set to either $true or $false - Used by New-ADUser to determine if the user is prompted to change their password upon first logon
    
    .PARAMETER PasswordNeverExpires
    Set to either $true or $false - Used by New-ADUser to determine if the users password should never expire

    .EXAMPLE
    Create a new user - FirstNameDotLastName Convention

    New-UserHire -FirstNameDotLastNameConvention $True -FirstInitialLastNameConvention $False -FirstName "Bob" -LastName "Builder" -Path 'OU=Shane Users,DC=ad,DC=smhcomputers,DC=com' -License "Basic"
    
    .EXAMPLE
    Create a new user - FirstInitialLastName Convention 

    New-UserHire -FirstNameDotLastNameConvention $False -FirstInitialLastNameConvention $True -FirstName "Bob" -LastName "Builder" -Path 'OU=Shane Users,DC=ad,DC=smhcomputers,DC=com' -License "Basic"

    .EXAMPLE
    
    Create a user calling all parameters - FirstNameDotLastName Convention

    New-UserHire -FirstNameDotLastNameConvention $True -FirstInitialLastNameConvention $False -EmailAddress "Bob.Builder@smhcomputers.com" -ProxyDomain "balls.com" -FirstName "Bob" -LastName "Builder" -Path 'OU=Shane Users,DC=ad,DC=smhcomputers,DC=com' -OfficePhone "561-319-5196" -Description "This is my new user" -CannotChangePassword $False -ChangePasswordAtLogon $True -PasswordNeverExpires $False -License "Basic"

    .EXAMPLE
    Create a user calling all parameters - FirstInitialLastName Convention

    New-UserHire -FirstNameDotLastNameConvention $False -FirstInitialLastNameConvention $True -EmailAddress "Bob.Builder@smhcomputers.com" -ProxyDomain "balls.com" -FirstName "Bob" -LastName "Builder" -Path 'OU=Shane Users,DC=ad,DC=smhcomputers,DC=com' -OfficePhone "561-319-5196" -Description "This is my new user" -CannotChangePassword $False -ChangePasswordAtLogon $True -PasswordNeverExpires $False -License "Basic"

    .EXAMPLE
    Create a user with a proxy address as their primary proxy email - FirstNameDotLastName Convention

    New-UserHire -FirstNameDotLastNameConvention $True -FirstInitialLastNameConvention $False -FirstName "Bob" -LastName "Builder" -ProxyDomain "smhcomputers.com" -Path "OU=Shane Users,DC=ad,DC=smhcomputers,DC=com" -License "Basic"

    .NOTES
    Prerequisites:

    Installation and import of Microsoft Graph PowerShell module can be installed and imported by running: 
    Install-Module –Name Microsoft.Graph
    Import-Module Microsoft.Graph

    Must be ran as administrator (domain or local) from a Domain Controller:
    Azure AD Connect tool must be installed
    Azure AD Sync Service must be running

    Must use an office 365 account with Global administrator role to connect to tenant
    #>
    

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $True, Mandatory = $True)]
        [ValidateNotNull()]
        [SecureString]$Credential,
   
        [Parameter(Mandatory = $True)] # Boolean - takes $true or $false
        [boolean]$FirstNameDotLastNameConvention,
        
        [Parameter(Mandatory = $True)] # Boolean - takes $true or $false
        [boolean]$FirstInitialLastNameConvention,

        [Parameter(Mandatory = $False)]
        [String]$EmailAddress = $Null,

        [Parameter(Mandatory = $False)]
        [ValidateSet("Basic", "Standard", "Premium", "ExoPlan1", "ExoPlan2", "Enterprise1", "Enterprise3", "Enterprise5")]
        [String]$License = $Null,

        [Parameter(Mandatory = $False)]
        [String]$PrimaryDomain,

        [Parameter(Mandatory = $False)]
        [String]$ProxyDomain,

        [Parameter(Mandatory = $True)]
        [String]$FirstName,

        [Parameter(Mandatory = $True)]
        [String]$LastName,

        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $False)]
        [String]$OfficePhone = $Null,

        [Parameter(Mandatory = $False)]
        [String]$Description = $Null,

        [Parameter(Mandatory = $False)]
        [String[]]$Groups = $Null,

        [Parameter(Mandatory = $False)] # Boolean - takes $true or $false
        [boolean]$CannotChangePassword = $False,

        [Parameter(Mandatory = $False)] # Boolean - takes $true or $false
        [boolean]$ChangePasswordAtLogon = $True,

        [Parameter(Mandatory = $False)] # Boolean - takes $true or $false
        [boolean]$PasswordNeverExpires = $False 
    )

    $PrimaryDomain = Get-ADDomain | Select-Object -ExpandProperty DNSRoot # Get DNS Root for primary domain name
    $CheckForSubDomain = $PrimaryDomain.IndexOf(".") # Check for sub domains = 2
    $DisplayName = $FirstName + " " + $LastName # Calculating display name
    
    if ($CheckForSubDomain -eq 2) {
        $PrimaryDomain = $PrimaryDomain.Substring($CheckForSubDomain + 1) # Check for sub domains in AD environment - will remove the subdomain, and leave the primary domain name
    }

    if ($FirstNameDotLastNameConvention -eq $True) {
        $SamAccountName = $FirstName + "." + $LastName
    }
    elseif ($FirstInitialLastNameConvention -eq $True) {
        $SamAccountName = $FirstName[0] + $LastName
    }

    $UPN = "$SamAccountName@$PrimaryDomain"

    $Attributes = @{
        Name                  = $DisplayName
        Enabled               = $True
        SamAccountName        = $SamAccountName
        UserPrincipalName     = $UPN
        DisplayName           = $DisplayName
        GivenName             = $FirstName
        Surname               = $LastName
        AccountPassword       = $Credential 
        OfficePhone           = $OfficePhone
        CannotChangePassword  = $CannotChangePassword
        ChangePasswordAtLogon = $ChangePasswordAtLogon
        PasswordNeverExpires  = $PasswordNeverExpires 
        Description           = $Description
        Path                  = $Path
    }
    New-ADUser @Attributes # Create a new user object and pass in values stored in parameters

    if ($EmailAddress) {
        Set-ADUser -Identity $SamAccountName -EmailAddress $EmailAddress
    }
    elseif (!$EmailAddress) {
        $EmailAddress = "$SamAccountName@$PrimaryDomain" # Set the default email if one is not passed in
        Set-ADUser -Identity $SamAccountName -EmailAddress $EmailAddress
    }

    if ($ProxyDomain) {
        # If value is provided to Proxy Domain parameter - the proxy address is added to new user account
        Set-ADUser $SamAccountName -Add @{ProxyAddresses = "SMTP:" + "$SamAccountName@$ProxyDomain" }
    }

    if ($Groups) {
        # For loop to add array of groups to user account
        ForEach ($Group in $Groups) {
            Add-ADGroupMember -Members $SamAccountName -Identity $Group
        }
    }

    Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.ReadWrite.All" | Out-Null # Connect to Microsoft Graph API
    
    # Start-Sleep functionality waits until the user account has had time to sync to Azure AD
    $LastSync = Get-MgOrganization | Select-Object -ExpandProperty OnPremisesLastSyncDateTime # Get Last sync time
    $WaitTime = 0

    Import-Module ADSync 
    Start-ADSyncSyncCycle -PolicyType 'Delta' # Run Sync to Office 365

    do { 
        Write-Warning "Syncing user account to Office 365 - Waiting until sync completes"
        $WaitTime += 5
        Start-Sleep $WaitTime # Sleep incrementing each loop by 5 seconds until user account syncs
        $CurrentSync = Get-MgOrganization | Select-Object -ExpandProperty OnPremisesLastSyncDateTime
    } until ($CurrentSync -ne $LastSync) # While Current and Last sync variable are equal, sync has yet to take place to Office 365 / Azure AD

    If ($License) {
        # If license key passed in equals a certain value, set the Sku ID
        $Licenses = @{
            "Basic"       = "3b555118-da6a-4418-894f-7df1e2096870" # Business Basic - O365_BUSINESS_ESSENTIALS 
            "Standard"    = "f245ecc8-75af-4f8e-b61f-27d8114de5f3" # Business Standard - O365_BUSINESS_PREMIUM
            "Premium"     = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46" # Business Premium - SPB
            "ExoPlan1"    = "4b9405b0-7788-4568-add1-99614e613b69" # Exchange Online (Plan 1) - EXCHANGESTANDARD
            "ExoPlan2"    = "19ec0d23-8335-4cbd-94ac-6050e30712fa" # Exchange Online (PLAN 2) - EXCHANGEENTERPRISE
            "Enterprise1" = "18181a46-0d4e-45cd-891e-60aabd171b4e" # Enterprise 1 - STANDARDPACK
            "Enterprise3" = "6fd2c87f-b296-42f0-b197-1e91e994b900" # Enterprise 3 - ENTERPRISEPACK
            "Enterprise5" = "c7df2760-2c81-4ef7-b578-5b5392b571df" # Enterprise 5 - ENTERPRISEPREMIUM
        }
        if ($Licenses.ContainsKey($License)) {
            $SkuId = $Licenses[$License]
        }  
    } # End if statement     

    $Id = Get-MGUser | Where-Object UserPrincipalName -eq $UPN | Select-Object -ExpandProperty Id
    Update-MgUser -UserId $Id -UsageLocation "US" # Set Usage Location for account
    Set-MgUserLicense -UserId $Id -AddLicenses @{SkuId = $SkuId } -RemoveLicenses @() # License account
    Get-MgUserLicenseDetail -UserId $Id | Select-Object SkuPartNumber # Confirm license

    Write-Host "Created User: $UserPrincipalName, synced to Office 365 at $CurrentSync"
    
} # End function