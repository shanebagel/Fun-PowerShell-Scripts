function Set-AutomaticLogin {
    # Start function

    <#
.SYNOPSIS
Sets credentials to automatically login to a windows local or domain account

.DESCRIPTION
Sets registry keys in the follow location HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
Registry keys are AutoAdminLogin, DefaultUsername, DefaultPassword, and DefaultDomainName 

.PARAMETER Credential
Pass in a pscredential object by calling Get-Credential and storing it in a variable 

.PARAMETER ComputerName
Hostname of the machine you're enabling automatic logins on. Defaults to the $env:COMPUTERNAME variable

.PARAMETER Domain
FQDN of the environment you're running the script in. Defaults to the $env:USERDOMAIN variable

.EXAMPLE
DomainName parameter switch used if account is apart of a domain
Set-AutomaticLogin -Credential $Credential -ComputerName $ComputerName -Domain

.EXAMPLE
Setting automatic login credentials on local computer, with a local account
Set-AutomaticLogin -Credential $Credential 

.NOTES
Must be ran as local or domain administrator
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [pscredential]$Credential,

        [Parameter(Mandatory = $false)]
        [switch]$Domain,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String]$ComputerName = $env:COMPUTERNAME
    ) 

    begin {
        $Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        $Properties = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
        Set-Location $Path
    }

    process {

        switch ($Properties) { # Switch to check if registry key properties are null
            { $null -eq $_.AutoAdminLogin } {
                New-ItemProperty -Name AutoAdminLogin -Path $Path -PropertyType "String"
            }

            { $null -eq $_.DefaultUserName } {
                New-ItemProperty -Name DefaultUserName -Path $Path -PropertyType "String"
            }

            { $null -eq $_.DefaultPassword } {
                New-ItemProperty -Name DefaultPassword -Path $Path -PropertyType
            }
        } # End switch construct

        Set-ItemProperty -Name AutoAdminLogin -Value "1" -Path $Path
        Set-ItemProperty -Name DefaultUserName -Value $Credential.UserName -Path $Path
        Set-ItemProperty -Name DefaultPassword -Value $Credential.Password -Path $Path

        if ($Domain) {
    
            if ($null -ne $Properties.DefaultDomainName) {
                Set-ItemProperty -Name DefaultDomainName -Value $env:USERDOMAIN -Path $Path -PropertyType
            }
            else {
                New-ItemProperty -Name DefaultDomainName -Value $env:USERDOMAIN -Path $Path -PropertyType
            }

        } # End if

    } # End process block

} # End function