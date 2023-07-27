function New-UserHire {


    # In-progress


    <#
    .SYNOPSIS
    Fully creates a new user account

    .DESCRIPTION
    Creates a new user account, sets a secure password for the account, adds proxy addresses to on-premise account,
    add user to relevant groups, runs a delta sync, licenses out office 365 mailbox, 
    sends an encrypted email with all relevant information to a defined email

    .PARAMETER Credential
    Credential for new user. Set a password as a secure string. You can either set a password automatically without running the function with -Credential - it will automatically prompt you, or you can create a secure string object first and pass it in

    .PARAMETER FirstNameDotLastNameConvention
    Pass in either $true or $false if the username is first.last - Example: Bob Builder -> bob.builder

    .PARAMETER FirstInitialLastNameConvention
    Pass in either $true or $false if the username is flast - Example: Bob Builder -> bbuilder

    .PARAMETER EmailAddress
    Email address of the employee - if you don't include a primary domain - the email will default to the on-premise UPN of the new user - which is SamAccountName@Domain.com

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

    .PARAMETER CannotChangePassword 
    Set to either $true or $false - Used by New-ADUser to determine if the user is allowed to change their own account password

    .PARAMETER ChangePasswordAtLogon 
    Set to either $true or $false - Used by New-ADUser to determine if the user is prompted to change their password upon first logon
    
    .PARAMETER PasswordNeverExpires
    Set to either $true or $false - Used by New-ADUser to determine if the users password should never expire

    .EXAMPLE
    Create a new user - FirstNameDotLastName Convention

    New-UserHire -FirstNameDotLastNameConvention $True -FirstInitialLastNameConvention $False -FirstName "Bob" -LastName "Builder" -Path 'OU=Shane Users,DC=ad,DC=smhcomputers,DC=com'
    
    .EXAMPLE
    Create a new user - FirstInitialLastName Convention 

    New-UserHire -FirstNameDotLastNameConvention $False -FirstInitialLastNameConvention $True -FirstName "Bob" -LastName "Builder" -Path 'OU=Shane Users,DC=ad,DC=smhcomputers,DC=com'

    .EXAMPLE
    
    Create a user calling all parameters - FirstNameDotLastName Convention

    New-UserHire -FirstNameDotLastNameConvention $True -FirstInitialLastNameConvention $False -EmailAddress "Bob.Builder@smhcomputers.com" -ProxyDomain "balls.com" -FirstName "bob" -LastName "builder" -Path 'OU=Shane Users,DC=ad,DC=smhcomputers,DC=com' -OfficePhone "561-319-5196" -Description "This is my new user" -CannotChangePassword $False -ChangePasswordAtLogon $True -PasswordNeverExpires $False

    .EXAMPLE
    Create a user calling all parameters - FirstInitialLastName Convention

    New-UserHire -FirstNameDotLastNameConvention $False -FirstInitialLastNameConvention $True -EmailAddress "Bob.Builder@smhcomputers.com" -ProxyDomain "balls.com" -FirstName "bob" -LastName "builder" -Path 'OU=Shane Users,DC=ad,DC=smhcomputers,DC=com' -OfficePhone "561-319-5196" -Description "This is my new user" -CannotChangePassword $False -ChangePasswordAtLogon $True -PasswordNeverExpires $False

    .EXAMPLE
    Create a user with a proxy address as their primary proxy email - FirstNameDotLastName Convention

    New-UserHire -FirstNameDotLastNameConvention $True -FirstInitialLastNameConvention $False -FirstName "Bob" -LastName "Builder" -ProxyDomain "smhcomputers.com" -Path "OU=Shane Users,DC=ad,DC=smhcomputers,DC=com"

    .NOTES
    Must be ran from a Domain Controller as either a user with domain administrator, local administrator, or server operator role

    
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

    if ($EmailAddress -eq $null) {
        $EmailAddress = "$SamAccountName@$PrimaryDomain"
    }

    $Attributes = @{
        Name                  = $DisplayName
        Enabled               = $True
        SamAccountName        = $SamAccountName
        UserPrincipalName     = "$SamAccountName@$PrimaryDomain"
        DisplayName           = $DisplayName
        GivenName             = $FirstName
        EmailAddress          = $EmailAddress
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

    if ($ProxyDomain) {
        # If value is provided to Proxy Domain parameter - the proxy address is added to new user account
        Set-ADUser $SamAccountName -Add @{ProxyAddresses = "SMTP:" + "$SamAccountName@$ProxyDomain" }
    }

    # Steps
    # Check if the user account already exists in AD - Done - New-ADUser does this
    # Create a user account - Done
    # set a secure password - Done
    # store password securely
    # add proxy addresses to on-premise account - Done
    # add user to relevant groups
    # runs a delta sync
    # licenses out office 365 mailbox
    # sends an encrypted email with all relevant information to a defined email
    # Creates a log file with relevant information regarding new hire 


} # End function