function Get-BitlockerStatus {

    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true
        )]
        [String[]]$ComputerName
    )

    $Status = Get-CimInstance -ClassName "Win32_Encryptablevolume" -Namespace "root\cimv2\security\MicrosoftVolumeEncryption" -ComputerName $ComputerName | Where-Object { $_.DriveLetter -eq "C:" }
        
    switch ($Status.ProtectionStatus) {
            ("0") { $return = "Disabled" }
            ("1") { $return = "Enabled" }
            ("2") { $return = "Unknown" }
    }

    $Status | Select-Object @{Label = "Hostname"; Expression = { $env:COMPUTERNAME } } , DriveLetter, @{Label = "BitlockerStatus"; Expression = { return $return } }
}
