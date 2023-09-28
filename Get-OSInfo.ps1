function Get-OSInfo {

    Param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true, 
            ValueFromPipeline = $true
        )]
        [String[]]$ComputerName = $Env:ComputerName
    )

    $System = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $ComputerName
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName
    $BIOS = Get-CimInstance -ClassName Win32_BIOS -ComputerName $ComputerName
    
    $ComputerObject = [ordered]@{
        'Hostname'            = $System.DNSHostName
        'System Manufacturer' = $System.Manufacturer
        'System Model'        = $System.Model
        'Operating System'    = $OS.Caption
        'OS Architecture'     = $OS.OSArchitecture
        'Last Boot Time'      = $OS.LastBootUpTime
        'Install Date'        = $OS.InstallDate
        'OS Version'          = $OS.Version
        'Build Number'        = $OS.BuildNumber
        'Serial Number'       = $OS.SerialNumber
        'BIOS Name'           = $BIOS.Name
        'BIOS Manufacturer'   = $BIOS.Manufacturer
        'BIOS Version'        = $BIOS.Version
    }

    $OSInfo = New-Object -Type PSObject -Property $ComputerObject
    Write-Output $OSInfo

} # End function