function Start-ProfileRebuild { # Start function

<#
.SYNOPSIS 
Starts rebuilding windows profile by removing registry keys associated with user account, renaming windows profile, and rebooting to release any locks on profile

.DESCRIPTION
Updates C:\Users\<Profile> folder in Users directory to OLD-ProfileName
Removes registry keys associated with SID: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\<UserSID>
Checks if machine has been online for more than an hour 
Reboots to release locks on profile

.PARAMETER UserName
Username of the user account being rebuilt

.PARAMETER ProfileName
Profile folder name of the profile being rebuilt

.PARAMETER ComputerName
Hostname of the machine you're running the script against

.EXAMPLE
Start-ProfileRebuild -ComputerName "Shaneserver" -ProfileName "bob" -UserName "bob"

.NOTES
Must be ran before Move-ProfileData.ps1

#>

    [CmdletBinding()]
    Param ( 
        [Parameter(ValueFromPipelineByPropertyName = $True, Mandatory = $True)]
        [String]$ComputerName,

        [Parameter(Mandatory = $True)]
        [String]$ProfileName,

        [Parameter(Mandatory = $True)]
        [String]$UserName
    )

    begin { # Begin block
        $LastBootUpTime = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime }
        $LocalDateTime = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty LocalDateTime }
        $TimeDifference = New-TimeSpan -Start $LocalDateTime -End $LastBootUpTime
  
        if ($TimeDifference.Hours -ne 0) { # Checks if machine has been online for more than an hour
            Write-Warning "Power cycling machine to release any profile locks as it's been online for more than one hour"
            Write-Warning "Re-run script after reboot completes"
            Start-Sleep -Seconds 10
            Invoke-Command -ComputerName $ComputerName -ScriptBlock { Restart-Computer -Force } # Reboot workstation to release locks on profile
            exit # Terminate script and must be reran
        } 
    }

    process { # Process block
        Set-Location "C:\Users"; Rename-Item $ProfileName "OLD-$ProfileName" # Renames user profile by appending the word "OLD"
        $SID = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_UserAccount | Where-Object { $_.Name -eq $UserName } | Select-Object -ExpandProperty SID # Extract SID from the user account
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID" -recurse # Remove the registry keys associated with user profile
        Write-Warning "Profile renamed, registry keys cleared, rebooting machine to finalize changes"
        Write-Warning "Please sign back into windows with user credentials after reboot"
        Start-Sleep -Seconds 10
        Invoke-Command -ComputerName $ComputerName -ScriptBlock { Restart-Computer -Force } # Reboot workstation to release locks on profile    
    }

} # End function