>1. Name script file containing functions to My-ModuleName.psm1 <br>
Rename My-Script.ps1 My-ModuleName.psm1 <br>

>2. Run $env:PSModulePath for Module file locations <br>
$env:psmodulepath

>3. Change directory to one of the PSModulePath directories and create a Module directory	
New-Item -Path .\My-ModuleName -ItemType Directory

>4. This folder must have the same name as the Module file	
My-ModuleName\My-ModuleName.psm1

>5. Create a symbolic link for your .psm1 file in the new Module directory 
New-Item -ItemType SymbolicLink -Path .\My-ModuleName.psm1 -Target 'LocationOfModuleFile'

>6. Create a .psd1 Manifest file to add metadata to Module
New-ModuleManifest

>7. Export all functions by updating FunctionToExport line in the .psd1 file	
FunctionsToExport = "My-Function1", "My-Function2"

>8. Set the correct Execution Policy to Import a Module file
Set-ExecutionPolicy <Unrestricted/Bypass>

>9. Run Import-Module to import the Module
Import-Module <FilePathToModule>

>10. Run Functions from Module by calling the scripts Functions
My-Function