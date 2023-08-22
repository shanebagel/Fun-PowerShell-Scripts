# PowerShell Scripts!

I've written everything from scratch. <br>

I try to keep scripts & functions looking as native to real PowerShell commands as possible. <br>

Help files are included for each, each file gets imported as a module for convenience, and a symbolic link gets pointed to a module directory. <br>

# Process for importing modules:
>1. Run $env:PSModulePath <br>

>2. Put module file & manifest file in a directory contained in the PSModulePath variable' <br>

>3. Import-Module "ModuleName" - Imports Module into session <br>

>4. Get-Module - Verify the Module is loaded <br>
