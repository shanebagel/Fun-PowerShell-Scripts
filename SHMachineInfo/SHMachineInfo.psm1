function Get-MachineInfo { # Start function

<#

.SYNOPSIS
Gets critical information from a windows workstation

.DESCRIPTION
Retrieves information on full system information, storage, windows updates, hardware, software installed, AV status, firewall status, networking information, disk / resource usage, last 20 event logs, local users / groups, attached network shares, last boot time, uptime, installed printers, wifi information, cached wifi credentials, battery information, critical environment variables, detailed list of user profiles with creation date, firewall configuration, relevant services/processes, bitlocker status, installed windows roles and features, domain information, and applied computer based group policy settings

    System Information:
        Hostname
        Operating System
        OS Version
        System Manufacturer
        System Model
        BIOS Version

	Get-CoreInfo.ps1

    Storage Information:
        Hard Drive(s) - Total and Free Space
        Drive Letters and Types

	Get-LocalStorage.ps1

    Network Information:
        IP Address
        Subnet Mask
        Default Gateway
        DNS Servers
        Network Adapters

	Get-NetInfo.ps1

    User Information:
        Currently logged-in user(s)
        User profile information

	Get-SysUser.ps1

    Installed Software:
        List of installed software packages

	Get-Package.ps1

    Hardware Information:
        GPU Information
        Network Adapters
        USB Devices

	Get-HW.ps1

    System Uptime:
        The amount of time the computer has been running since the last reboot

	Get-Uptime.ps1 

    Security Information:
        Antivirus Software and Status
        Firewall Status
	Detailed information about hardware components (e.g., motherboard, memory modules, hard drives)

	Get-SecInfo.ps1

    Windows Updates:
        Last checked for updates
        Last installed updates

	Get-UpdateInfo.ps1

    Event Logs:
        Recent system events or errors

	Get-LocalEvent.ps1

    Printers:
        List of installed printers

	Get-LocalPrinter.ps1    

    Network Shares:
        List of shared folders and their permissions

	Get-NetShare.ps1

    Firewall Configuration:
        Settings related to Windows Firewall rules

	Get-FirewallConfig.ps1

    User Profiles:
        Detailed information about user profiles on the computer

	Get-LocalUser.ps1

    Running Processes:
        List of running processes with their resource usage (CPU, memory)

	Get-CurrentProcessInfo.ps1

    System Services:
        List of system services, their status, and startup type
        
	Get-CurrentServiceinfo.ps1

    Power Information:
        Battery status and health (for laptops)
        Power plan settings

	Get-PowerInfo.ps1

    System Environment Variables:
        Display important system environment variables

	Get-EnvVar.ps1

    BitLocker Status:
        Check if BitLocker encryption is enabled and the encryption status of drives

	Get-BitlockerStatus.ps1

    Group Policy Settings:
        Check and list applied Group Policy computer  settings

	Get-GPOInfo.ps1

    Installed Windows Features and Roles:
        Information about Windows features and roles installed on system

	Get-InstalledRoleInfo.ps1

    Domain information:
        Gets information related to domain that machine is joined to

    Get-DomainInfo.ps1

.PARAMETER ComputerName
Hostname of the machine the script is being ran against. Default is localhost

.EXAMPLE
Get-MachineInfo -ComputerName "Shaneserver"

.NOTES
Must be ran with an account with some level of administrative privileges, local, or domain admin preferred 

#>

[CmdletBinding()]
Param(

[Parameter(Mandatory = $false)]
[String]$ComputerName

)

Get-BitlockerStatus -ComputerName $ComputerName

Get-CoreInfo -ComputerName $ComputerName

Get-CurrentProcessInfo -ComputerName $ComputerName

Get-CurrentServiceInfo -ComputerName $ComputerName

Get-DomainInfo -ComputerName $ComputerName

Get-EnvVar -ComputerName $ComputerName

Get-FirewallConfig -ComputerName $ComputerName

Get-GPOInfo -ComputerName $ComputerName

Get-HW -ComputerName $ComputerName

Get-InstalledRoleInfo -ComputerName $ComputerName

Get-LocalEvent -ComputerName $ComputerName

Get-LocalPrinter -ComputerName $ComputerName

Get-LocalStorage -ComputerName $ComputerName

Get-LocalUser -ComputerName $ComputerName

Get-NetInfo -ComputerName $ComputerName

Get-NetShare -ComputerName $ComputerName

Get-Package -ComputerName $ComputerName

Get-PowerInfo -ComputerName $ComputerName

Get-SecInfo -ComputerName $ComputerName

Get-SysUser -ComputerName $ComputerName

Get-Update -ComputerName $ComputerName

Get-UpdateInfo -ComputerName $ComputerName

} # End function