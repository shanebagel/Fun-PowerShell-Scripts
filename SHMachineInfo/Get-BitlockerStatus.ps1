function Get-BitlockerStatus {

Param(
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [String]$ComputerName
)

    if ($PSVersionTable.PSVersion.Major -ge 3) {
        $Status = Get-CimInstance -ClassName "Win32_Encryptablevolume" -Namespace "root\cimv2\security\MicrosoftVolumeEncryption" -ComputerName $ComputerName | Where-Object { $_.DriveLetter -eq "C:" }
        
        switch ($Status.ProtectionStatus) {
            ("0") { $return = "Disabled" }
            ("1") { $return = "Enabled" }
            ("2") { $return = "Unknown" }
        }

        $Status | Select-Object @{Label = "Hostname"; Expression = { $env:COMPUTERNAME } } , DriveLetter, @{Label = "BitlockerStatus"; Expression = { return $return } }

    }
    else {
        $Status = Get-WmiObject -ClassName "Win32_EncryptableVolume" -Namespace "root\CIMV2\Security\MicrosoftVolumeEncryption" -ComputerName $ComputerName | Where-Object { $_.DriveLetter -eq "C:" }  
        
        switch ($Status.ProtectionStatus) {
            ("0") { $return = "Disabled" }
            ("1") { $return = "Enabled" }
            ("2") { $return = "Unknown" }
        }

        $Status | Where-Object { $_.DriveLetter -eq "C:" } | Select-Object @{Label = "Hostname"; Expression = { $_.__Server } }, DriveLetter, @{Label = "BitlockerStatus"; Expression = { $_.ProtectionStatus } }
    }
}