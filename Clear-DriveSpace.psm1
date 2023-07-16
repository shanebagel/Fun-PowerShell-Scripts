function Clear-DriveSpace {
<#
.SYNOPSIS
Clear-DriveSpace takes a computer name and runs through a set of processes that clears out unused drive space on a local computer.

.DESCRIPTION
Clear-DriveSpace is a tool that can be run on systems with low drive space. 

.PARAMETER ComputerName
ComputerName is a required parameter for this script. 

.EXAMPLE
Clear-DriveSpace -ComputerName "Shanelaptop"

.NOTES 
Must be run as an administrator.
Must be running at least PowerShell Version 5.0 - check with $PSVersionTable.
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [ValidatePattern("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$")]
        [String]$ComputerName = 'localhost'
    )

    # Helper function to delete files
    function Remove-Files {
        Param (
            [Parameter(Mandatory=$true)]
            [String]$Path
        )
        if (Test-Path -Path $Path) {
            Set-Location $Path
            Get-ChildItem * | Remove-Item -Recurse -Force
            Write-Host "Clearing $Path." -ForeGroundColor Black -BackGroundcolor White
            Start-Sleep 3
        }
        else {
            Write-Host "Error: $Path doesn't exist." -ForeGroundColor Black -BackGroundcolor Yellow
            Start-Sleep 3
        }
    }

    # Begin script
    Write-Host "Thanks for running my cleanup utility! Let's begin cleaning up disk space."  -ForeGroundColor Black -BackGroundcolor White

    # Check connectivity
    if (!(Test-Connection $ComputerName -Quiet)) {
        Write-Warning "Error: Cannot connect to $ComputerName. Please verify computer name and network connectivity."  -ForeGroundColor Yellow -BackGroundcolor Black
        return
    }

    # Clear temp files
    $Temp = 'C:\Temp'
    Remove-Files -Path $Temp

    # Remove least cumulative updates contents
    $Lcu = 'C:\Windows\servicing\lcu'
    Remove-Files -Path $Lcu

    # Remove Software Distribution contents
    $Swdistro = 'C:\Windows\SoftwareDistribution'
    Remove-Files -Path $Swdistro

    # Remove Recycle Bin contents
    $Recycle = 'C:\$RECYCLE.BIN'
    Remove-Files -Path $Recycle

    Write-Host "Downloading drive cleanup utilities." -ForeGroundColor Black -BackGroundcolor White
    $treesize = 'http://www.jam-software.com/treesize_free/TreeSizeFreeSetup.exe'
    $path = "$Temp\treesize.exe"
    Start-BitsTransfer -Source $treesize -Destination $path

    # Download Wicleanup
    $wicleanupc = "https://fm.solewe.com/vfm-admin/vfm-downloader.php?q=0&sh=98b0a30e8e36652bab02f90771e8128a&share=8564959590d7c06333f81e5b7ee18fc2"
    $path = "$Temp\wicleanup.7z"
    Start-BitsTransfer -Source $wicleanupc -Destination $path

    # Install 7Zip module to extract Wicleanup
    Install-Module -Name 7Zip4PowerShell -Force
    $wicleanupzip = "$Temp\wicleanup.7z"
    Expand-7Zip -ArchiveFileName $wicleanupzip -TargetPath "$Temp\wicleanup"

    Write-Host "Running Wicleanup process - Removing all unused MSP/MSI files - Click OK when complete" -ForeGroundColor Black -BackGroundcolor White
    Set-Location "$Temp\wicleanup"
    .\WICleanupC.EXE -s | Out-Null # Running Wicleanup and piping output to Out-Null so PWSH waits until the process finishes

    Write-Host "Running disk cleanup utility." -ForeGroundColor Black -BackGroundcolor White
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/verylowdisk" -Wait

    Write-Host "Starting 'Programs and Features menu' - Please manually remove unused programs." -ForeGroundColor Black -BackGroundcolor White
    Start-Process -FilePath "appwiz.cpl" | Out-Null

    Write-Host "Starting 'TreeSize' - Please finish exe installation and examine what is consuming remaining drive space." -ForeGroundColor Black -
