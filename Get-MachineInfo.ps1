function Get-MachineInfo {

<#

.SYNOPSIS
Gets critical information from a windows workstation

.DESCRIPTION
Retrieves information on full system information, storage, windows updates, hardware, software installed, AV status, firewall status, networking information, disk / resource usage, last 20 event logs, local users / groups, attached network shares, last boot time, uptime, installed printers, wifi information, cached wifi credentials, battery information, critical environment variables, detailed list of user profiles with creation date, firewall configuration, relevant services/processes, bitlocker status, and applied computer based group policy settings

    System Information:
        Hostname
        Operating System
        OS Version
        System Manufacturer
        System Model
        BIOS Version
        Processor Information (e.g., CPU type, speed, number of cores)
        RAM (Total and Available)

    Storage Information:
        Hard Drive(s) - Total and Free Space
        Drive Letters and Types

    Network Information:
        IP Address
        Subnet Mask
        Default Gateway
        DNS Servers
        Network Adapters

    User Information:
        Currently logged-in user(s)
        User profile information

    Installed Software:
        List of installed software packages

    Hardware Information:
        GPU Information
        Network Adapters
        USB Devices

    System Uptime:
        The amount of time the computer has been running since the last reboot

    Security Information:
        Antivirus Software and Status
        Firewall Status

    Windows Updates:
        Last checked for updates
        Last installed updates

    Event Logs:
        Recent system events or errors

    Hardware Inventory:
        Detailed information about hardware components (e.g., motherboard, memory modules, hard drives)

    Printers:
        List of installed printers
    
    Network Shares:
        List of shared folders and their permissions

    Firewall Configuration:
        Settings related to Windows Firewall rules

    User Profiles:
        Detailed information about user profiles on the computer

    Running Processes:
        List of running processes with their resource usage (CPU, memory)

    System Services:
        List of system services, their status, and startup type
        
    Power Information:
        Battery status and health (for laptops)
        Power plan settings

    System Environment Variables:
        Display important system environment variables

    BitLocker Status:
        Check if BitLocker encryption is enabled and the encryption status of drives.

    Group Policy Settings:
        Check and list applied Group Policy computer  settings.

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





}