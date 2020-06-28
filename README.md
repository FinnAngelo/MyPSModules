# MyPSModules

A bunch of handy powershell I use

## TOC ##

+ [Snippits](#Snippits)

## Snippits ##

Location of Modules

```powershell
$env:PSModulePath -split ';' 

# My Module path
[string] $MyModulesPath = $env:PSModulePath -split ';' | Where-Object -FilterScript { $_ -like "*$env:UserName*" -and $_ -like "*WindowsPowerShell\Modules*" }

# A Modules path
(Get-Module JFA.MyDevSecret).Path

```

Other Special Folders - see [Environment.SpecialFolder Enum](https://docs.microsoft.com/en-us/dotnet/api/system.environment.specialfolder)

```powershell
 [environment]::getfolderpath("Desktop")
```

Add **my** powershell modules

```powershell
$CurrentValue = [Environment]::GetEnvironmentVariable("PSModulePath", "User")
[Environment]::SetEnvironmentVariable("PSModulePath", $CurrentValue + [System.IO.Path]::PathSeparator + "D:\Cloud\Jon\OneDrive\Documents\WindowsPowerShell\Modules", "User")
```