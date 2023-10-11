function Confirm-TerminationInformation {

    Add-Type -AssemblyName PresentationCore, PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::YesNo

    $HRWarning = [System.Windows.MessageBoxImage]::Warning
    $HRWarningTitle = "Human Resources Warning"
    $HRWarningBody = "Has termination request been approved by HR, and Associate Director of HR been added as 'additional contact' to Ticket?"

    $TenantWarning = [System.Windows.MessageBoxImage]::Warning
    $TenantWarningTitle = "Tenant Warning"
    $TenantWarningBody = "Have you already verified external accounts have been terminated in other tenants?"

    $HRWarningObject = [System.Windows.MessageBox]::Show($HRWarningBody, $HRWarningTitle, $ButtonType, $HRWarning)

    $TenantWarningObject = [System.Windows.MessageBox]::Show($TenantWarningBody, $TenantWarningTitle, $ButtonType, $TenantWarning)

    if ($HRWarningObject -eq "No") {
        Write-Warning "Please confirm termination request is approved / submitted by HR before re-running script"
        break
    }

    if ($TenantWarningObject -eq "No") {
            
        $TenantIDs = @{
            'Tenant 1:' = "<Insert Tenant ID>"
            'Tenant 2:' = "<Insert Tenant ID2>"

        } 
        
        Write-Warning -Message "Please verify account is disabled in the following tenants:"
        $TenantIDs.GetEnumerator() | Select-Object @{name = 'Tenant'; expression = { $_.Key } }, @{name = 'Tenant ID'; expression = { $_.Value } }
    
        $Warning = @"
`nSteps to take on external account:
Disable account
Revoke sessions
Re-run termination script once these tasks are complete in other tenants
"@
        Write-Warning -Message $Warning
        break    
    } # End if
    
} # End function