function Get-EnvInfo {

<#
    .SYNOPSIS
    Get-EnvInfo retrieves remote or local system information with a controller script
    .DESCRIPTION
    Get-EnvInfo retrieves IP Addresses, Hostnames, Windows OS Versions, Detailed computer info, Name of Domain, Name of Forest, FSMO Roles, Exports all data to the Host and to a txt file.
    .PARAMETER ComputerName
    ComputerName is the hostname of the system you're retrieving information from.
    .PARAMETER Credential
    Credential is the Username of the user you're running the script with - use a local/domain administrator account.
    .EXAMPLE
    Get-EnvInfo -ComputerName "Shaneserver" -Credential "Admin"
    .NOTES 
    Must run the script as administrator.
    Must be running at least PowerShell verion 5.0 - Verify with $PSVersionTable
    #>
    
    
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
    [String[]]$ComputerName, # Array for Computer names
    [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
    [String]$Credential
)
foreach ($Computer in $ComputerName) {
    if (Test-Connection $Computer -Quiet) {
        Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock {
    
            Get-ADDomain | Select-Object @{name = 'Domain Name'; expression = { $_."Name" } }, @{name = 'Forest Name'; expression = { $_."Forest" } } | Add-Content -Path .\EnvironmentInformation.txt 
    
            Write-Verbose "Discovering all servers in environment" 
            Get-ADComputer -Filter { (OperatingSystem -like "*Server*") -and (Enabled -eq $true) } -Properties * | Select-Object DNSHostName, IPv4Address, OperatingSystem | Add-Content -Path .\EnvironmentInformation.txt # Discover servers 
                    
            Write-Verbose "Discovering Forest-Level Roles"
            Get-ADForest | Format-Table *Master | Add-Content -Path .\EnvironmentInformation.txt # Discover Forest-Level Roles
                    
            Write-Verbose "Discovering Domain-Level Roles"
            Get-ADDomain | Format-Table PDCEmulator, *Master | Add-Content -Path .\EnvironmentInformation.txt # Discover Domain-Level Roles
    
            Get-WindowsFeature -ComputerName $Computer | Where-Object { $_.InstallState -eq "installed" } | Add-Content -Path .\EnvironmentInformation.txt # Discover installed roles on each server
     
     
            Get-Content -Path .\EnvironmentInformation.txt
        }
    
    }
    else {
        Write-Warning "Error: Cannot connect to server $Computer - Please verify network connectivity"
    }
}

}

Get-EnvInfo