# Module Creation Process

1. Name script file containing functions to My-ModuleName.psm1 <br>
```Rename My-Script.ps1 My-ModuleName.psm1```<br>

2. Run $env:PSModulePath for Module file locations <br>
```$env:psmodulepath```<br>

3. Change directory to one of the PSModulePath directories and create a Module directory <br>
```New-Item -Path .\My-ModuleName -ItemType Directory``` <br>

4. This folder must have the same name as the Module file <br>	
```My-ModuleName\My-ModuleName.psm1``` <br>

5. Create a symbolic link for your .psm1 file in the new Module directory <br>
```New-Item -ItemType SymbolicLink -Path .\My-ModuleName.psm1 -Target 'LocationOfModuleFile'``` <br>

6. Create a .psd1 Manifest file to add metadata to Module <br>
```New-ModuleManifest``` <br>

7. Export all functions by updating FunctionToExport line in the .psd1 file	<br>
```FunctionsToExport = "My-Function1", "My-Function2"``` <br>

8. Set the correct Execution Policy to Import a Module file <br>
```Set-ExecutionPolicy <Unrestricted/Bypass>``` <br>

9. Run Import-Module to import the Module <br>
```Import-Module <FilePathToModule>``` <br>

10. Run Functions from Module by calling the scripts Functions <br>
```My-Function``` <br>