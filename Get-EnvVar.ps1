function Get-EnvVar {

    Param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true, 
            ValueFromPipeline = $true
        )]
        [String[]]$ComputerName = $Env:ComputerName
    )

 
    $Query = @( 
        $Env:ComputerName, 
        $Env:UserDNSDomain, 
        $Env:LogonServer, 
        $Env:Path, 
        $Env:PSModulePath,
        $PSEdition,
        $PSVersionTable
    )

    Invoke-Command -ComputerName $ComputerName -ScriptBlock { $Query }

    $EnvVars = [Ordered]@{
        'Computer Name'                 = $Query[0]
        'Domain'                        = $Query[1]
        'Logon Server (DC)'             = $Query[2]
        'Path Variable Directories'     = $Query[3] -Split ';' -join "`n"
        'PowerShell Module Directories' = $Query[4] -Split ';' -join "`n"
        'PowerShell Edition'            = $Query[5]
        'PowerShell Version'            = $Query[6].PSVersion.Major
    }

    $Vars = New-Object -Type PSObject -Property $EnvVars
    Write-Output $Vars

} # End function