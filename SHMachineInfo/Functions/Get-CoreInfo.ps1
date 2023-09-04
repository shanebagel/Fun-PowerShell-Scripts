function Get-CoreInfo {

Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [String]$ComputerName
)

Invoke-Command -ComputerName $ComputerName -ScriptBlock { $env:COMPUTERNAME } | Select-Object @{name='Hostname';exp={$_}} 

if ($PSVersionTable.PSVersion.Major -ge 3) {
    Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $ComputerName | Select-object @{name='System Manufacturer';exp={$_.Manufacturer}}, @{name='System Model';exp={$_.Model}}
    Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName | Select-Object OSArchitecture
    Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName | Select-Object @{name='Operating System';exp={$_.Caption}}
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {[System.Environment]::OSVersion.Version | Select-Object Major, Minor, Build, Revision | Format-Table}
    Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName | Select-Object SerialNumber
    Get-CimInstance -ClassName Win32_BIOS -ComputerName $ComputerName | select-object Name, Manufacturer, Version
}
else {
    Get-WmiObject -ClassName Win32_ComputerSystem -ComputerName $ComputerName | Select-object @{name='System | Select-Object Major, Minor, Build, Revision | Format-Table Manufacturer';exp={$_.Manufacturer}}, @{name='System Model';exp={$_.Model}}
    Get-WmiObject -ClassName Win32_OperatingSystem -ComputerName $ComputerName | select-Object OSArchitecture
    Get-WmiObject -ClassName Win32_OperatingSystem -ComputerName $ComputerName | Select-Object @{name='Operating System';exp={$_.Caption}}
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {[System.Environment]::OSVersion.Version | Select-Object Major, Minor, Build, Revision | Format-Table}
    Get-WmiObject -ClassName Win32_OperatingSystem -ComputerName $ComputerName | Select-Object SerialNumber
    Get-WmiObject -ClassName Win32_BIOS -ComputerName $ComputerName | select-object Name, Manufacturer, Version
}

} # End function