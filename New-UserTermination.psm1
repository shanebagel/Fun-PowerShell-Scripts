function New-UserTermination {


# In-progress



    <#
.SYNOPSIS
Fully disables a terminated user

.DESCRIPTION
Disables user object, creates a scambled password and resets password on account, moves user account to disabled user ou, removes all group memberships, runs delta sync to ensure office 365 account is disabled, clears any office 365/azure licenses, converts office 365 mailbox to a shared mailbox, hides shared mailbox from Global Address List (GAL), sends an email notifying relevant party of completed termination

.PARAMETER ou

.PARAMETER

.EXAMPLE

.NOTES
Must be ran from a Domain Controller as either a user with domain administrator, local administrator, or server operator role

#>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $True)]
        [value]$Param1,

        [Parameter(ValueFromPipeline = $True)]
        [value]$Param2


        # disabled users OU as parameter, UPN as parameter for username, credential to connect to O365
    )


    Install-Module ActiveDirectory -Wait
    Import-Module ActiveDirectory


    # Steps
    # Disables user object
    # creates a scambled password and resets password on account
    # clears any office 365/azure licenses
    # Remove all group memberships
    # moves user account to disabled user ou
    # runs delta sync to ensure office 365 account is disabled
    # converts office 365 account to a shared mailbox
    # hides shared mailbox from Global Address List (GAL)
    # sends an email notifying relevant party of completed termination
    # Creates a log file with relevant information regarding termination 


}