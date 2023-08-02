# PowerShell Scripts!

I've written everything from scratch. <br>

I try to keep scripts & functions looking as native to real PowerShell commands as possible. <br>

Help files are included for each, each file gets imported as a module for convenience, and a symbolic link gets pointed to a module directory. <br>

# Process for importing scripts as modules:
>1. Rename 'Verb-Noun'.ps1 file to 'Verb-Noun'.psm1 <br>

>2. New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\' -Type Directory -Name "Module-Directory" - Directory for module MUST match script name <br>

>3. Set-Location 'C:\Program Files\WindowsPowerShell\Modules\"Module-Directory"'

>4. New-Item -ItemType SymbolicLink -Path .\Verb-Noun.psm1 -Target 'C:\Users\admin\Scripts\Fun-PowerShell-Scripts\Verb-Noun.psm1' - Create a symbolic link from 'Scripts' directory to Module directory  

>5. Gpedit.msc -> Computer Configuration > Administrative Templates > Windows Components > Windows PowerShell. Change the “Turn on Script Execution <br>

>6. Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\PowerShell -Name ExecutionPolicy -Value ByPass <br>

>7. Import-Module "Module Name" - Import the Module to session <br>

>8. Get-Module - Verify the Module is loaded <br>
