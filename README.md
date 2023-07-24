# PowerShell Scripts!

I've written everything from scratch. <br>

Tried keeping the scripts looking as native to real PWSH commands as possible. <br>

Help files are included for each, and each file gets imported as a module for convenience <br>

# Process for importing scripts as modules:
>1. Rename 'Verb-Noun'.ps1 'Verb-Noun'.psm1 <br>

>2. New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\' -Type Directory -Name 'Verb-Noun' <br>

>3. Copy-Item .\'Verb-Noun'.psm1 'C:\Program Files\WindowsPowerShell\Modules\<Verb-Noun>\' # Directory for module name MUST match file name <br>

>4. Set-Location 'C:\Program Files\WindowsPowerShell\Modules' <br>

>5. Gpedit.msc -> Computer Configuration > Administrative Templates > Windows Components > Windows PowerShell. Change the “Turn on Script Execution <br>

>6. Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\PowerShell -Name ExecutionPolicy -Value ByPass <br>

>7. New-Item -ItemType SymbolicLink -Path .\Verb-Noun.psm1 -Target 'C:\Users\admin\Scripts\Fun-PowerShell-Scripts\Verb-Noun.psm1' # Create a symbolic link from 'Scripts' directory to Module directory 

>7. Import-Module 'Module Name' <br>

>8. Get-Module - verify the Module is loaded <br>
