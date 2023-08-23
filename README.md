# PowerShell Scripts!

I've written everything from scratch. <br>

I try to keep scripts & functions looking as native to real PowerShell commands as possible. <br>

Help files are included in each script, and each script can be ran as a stand-alone .ps1 file. <br>

Scripts can also be imported as modules by including their respective .psm1 and .psd1 files. <br>

# Process for importing scripts as modules:
1. Run $env:PSModulePath <br>

2. Create a directory in a module path with the same name as the module file minus the .psm1 file extension <br>

3. Place module file, manifest file, and script files in that directory contained in the PSModulePath variable' <br>

5. Import-Module "ModuleName" - Imports Module into session <br>

5. Get-Module; Get-Command -Module "ModuleName" - Verify the Module and functions are loaded <br>
