function Get-EnvInfo {

    <#
    .SYNOPSIS
    Get-EnvInfo retrieves remote or local system information with a controller script
    .DESCRIPTION
    Get-EnvInfo retrieves IP Addresses, Hostnames, Windows OS Versions, Detailed computer info, Name of Domain, Name of Forest, FSMO Roles, Exports all data to the Host and to a txt file.
    The script can be ran against remote systems using invoke-command.
    .PARAMETER ComputerName
    ComputerName is the hostname of the system you're retrieving information from.
    .PARAMETER Credential
    Specifies the user account credentials to use to run the script - use a local or domain administrator account. You will be prompted for a password
    .EXAMPLE
    Get-EnvInfo -ComputerName "Shaneserver" -Credential "Admin"
    .NOTES 
    Must run the script as administrator.
    Must be running at least PowerShell verion 5.0 - Verify with $PSVersionTable
    You must place the .psm1 module in a PSModulePath directory. 
    You import the Get-EnvInfo module with 'Import-Module Get-EnvInfo'
    #>
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String[]]$ComputerName, # Array for Computer names
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$Credential
    )

    BEGIN {}

    PROCESS {
        foreach ($Computer in $ComputerName) {
            if (Test-Connection $Computer -Quiet) {
                Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock {

                    Write-Host "Discovering the Domain Controller types" -ForeGroundColor Black -BackGroundcolor Yellow
                    Write-Host ""

                    $DCServices = ("GlobalCatalog", "KDC", "PrimaryDC")
                    $DCServices | ForEach-Object {
                        Write-Host "The $_ is:" -ForeGroundColor Black -BackGroundcolor Yellow
                        Get-ADDomainController -Discover -Service $_ | Select-Object Name, Site, IPv4Address
                    }
        
                    Write-Host "Discovering Domain & Forest" -ForeGroundColor Black -BackGroundcolor Yellow
                    Get-ADDomain | Select-Object @{name = 'Domain Name'; expression = { $_."Name" } }, @{name = 'Forest Name'; expression = { $_."Forest" } } | Format-Table  
            
                    Write-Host "Discovering all servers in environment" -ForeGroundColor Black -BackGroundcolor Yellow
                    Get-ADComputer -Filter { (OperatingSystem -like "*Server*") -and (Enabled -eq $true) } -Properties * | Select-Object DNSHostName, IPv4Address, OperatingSystem | Format-Table
            
                    Write-Host "Discovering all Domain Controllers in environment" -ForeGroundColor Black -BackGroundcolor Yellow
                    Get-ADDomainController -Filter * | Format-Table Name, Sites, IPv4Address, IsGlobalCatalog, IsReadOnly -AutoSize

                    Write-Host "Discovering Forest-Level Roles" -ForeGroundColor Black -BackGroundcolor Yellow
                    Get-ADForest | Format-Table *Master # Discover Forest-Level Roles
            
                    Write-Host "Discovering Domain-Level Roles" -ForeGroundColor Black -BackGroundcolor Yellow
                    Get-ADDomain | Format-Table PDCEmulator, *Master # Discover Domain-Level Roles

                    ForEach ($Computer in $ComputerName) {
                        Write-Host "Discovering Installed Roles & Features on computers provided" -ForeGroundColor Black -BackGroundcolor Yellow
                        Get-WindowsFeature | Where-Object { $Computer.InstallState -eq "installed" } | Format-Table # Discover installed roles on each server
                    }    

                    Write-Host "Discovering all enabled GPOs in Domain" -ForeGroundColor Black -BackGroundcolor Yellow
                    $Domain = Get-ADDomain | Select-Object -ExpandProperty DNSRoot -Wait
                    Get-GPO -All | Where-Object { $_.GpoStatus -like "*enabled*" } | Select-Object DisplayName, @{name = 'GPO ID'; expression = { $_."id" } }, Description | Format-Table

                } # End of invoke command
            } # End of if statement

            else {
                Write-Warning "Error: Cannot connect to server $Computer - Please verify network connectivity"
            }
        } # End of foreach loop
    } # End of process block
    END {}
} # End of function