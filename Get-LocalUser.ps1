function Get-LocalUser {

    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true, 
            ValueFromPipeline = $true
        )]
        [String[]]$ComputerName
    )

    $LocalUsers = Get-CimInstance -ClassName Win32_UserAccount -ComputerName $ComputerName
 
    $LocalUsers | Select-Object Name, SID, Domain, LocalAccount

} # End function