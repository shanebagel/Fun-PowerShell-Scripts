function New-UserHire {


# In-progress


    <#
    .SYNOPSIS
    Fully creates a new user account

    .DESCRIPTION
    Creates a new user account, sets a secure password for the account, adds proxy addresses to on-premise account, add user to relevant groups, runs a delta sync, licenses out office 365 mailbox, sends an encrypted email with all relevant information to a defined email

    .PARAMETER Path
    # DistinguishedName attribute of the OU you want the user to be created it. Defaults to 'Users' container

    .EXAMPLE
    New-UserHire -FirstName "Bob" -LastName "Builder" -FirstNameDotLastNameConvention $True -Path "OU=Shane Users,DC=ad,DC=smhcomputers,DC=com" -Manager "Shane Hartley" -OfficePhone "561-319-5196" -Description "New Bob the Builder account" -CannotChangePassword = $False -ChangePasswordAtLogon = $False

    .NOTES
    Must be ran from a Domain Controller as either a user with domain administrator, local administrator, or server operator role

    
    #>
    

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $True, Mandatory = $True)]
        [ValidateNotNull()]
        [pscredential]$Credential,

        [Parameter()] # Flag - doesn't require input
        [Switch]$FirstNameDotLastNameConvention,
        
        [Parameter()] # Flag - doesn't require input
        [Switch]$FirstInitialLastNameConvention,

        [Parameter(Mandatory = $True)]
        [String]$FirstName,

        [Parameter(Mandatory = $True)]
        [String]$LastName,

        [Parameter(Mandatory = $False)]
        [String]$Path,

        [Parameter(Mandatory = $False)]
        [String]$OfficePhone,

        [Parameter(Mandatory = $False)]
        [String]$Manager,

        [Parameter(Mandatory = $False)]
        [String]$Description,

        [Parameter(Mandatory = $False)] # Flag - doesn't require input
        [switch]$CannotChangePassword = $False,

        [Parameter(Mandatory = $False)] #  Flag - doesn't require input
        [switch]$ChangePasswordAtLogon = $True
    )
    
    $OtherAttributes = @{
        'OfficePhone'           = $OfficePhone
        'Manager'               = $Manager
        'CannotChangePassword'  = $CannotChangePassword
        'ChangePasswordAtLogon' = $ChangePasswordAtLogon
        'Description'           = $Description
        'Path'                  = $Path
    }

    $PrimaryDomain = Get-ADDomain | Select-Object -ExpandProperty DNSRoot
    $DisplayName = $FirstName + " " + $LastName

    if ($FirstNameDotLastNameConvention -eq $True) {
        $SamAccountName = $FirstName + "." + $LastName
        $UserPrincipalName = $FirstName + "." + $LastName
    }

    elseif ($FirstInitialLastNameConvention -eq $True) {
        $SamAccountName = $FirstName[0] + $LastName
        $UserPrincipalName = $FirstName[0] + $LastName
    }

#    try {
        New-ADUser -Enabled $True -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName@$PrimaryDomain -Name $DisplayName -DisplayName $DisplayName -GivenName $FirstName -Surname $LastName -AccountPassword $Credential.password -OtherAttributes @OtherAttributes
#    }

#    catch {
        Write-Warning "Error: Couldn't create account - check if user account already exists"
#    }

    # credential as parameter, UPN as parameter, Uses naming standards

    # Steps
    # Check if the user account already exists in AD
    # Create a user account
    # set a secure password 
    # add proxy addresses to on-premise account
    # add user to relevant groups
    # runs a delta sync
    # licenses out office 365 mailbox
    # sends an encrypted email with all relevant information to a defined email
    # Creates a log file with relevant information regarding new hire 


} # End function