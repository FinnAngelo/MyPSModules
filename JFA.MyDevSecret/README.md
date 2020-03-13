# JFA.MyDevSecret README.md #

http://www.finnangelo.com/powershell/2020/02/02/Powershell_Secrets.html

## To Test ##

I cloned my github repo to a folder on my desktop

```powershell
cd D:\Users\Jon\Desktop\GitHub\MyPSModules\JFA.MyDevSecret

Import-Module .\JFA.MyDevSecret

Invoke-Pester 

$secret = Read-Host -AsSecureString "Please enter your secret"

Set-MyDevSecretFromSecureString -key "KeyFromPrompt" -secureSecret $secret
Get-MyDevSecret "KeyFromPrompt"
```

## Suggestions ##

Because this is still in development, I didn't add the final to a `$ENV:PSModulePath`.

Instead, I added this to my `$Profile.CurrentUserAllHosts` file:
 
```powershell
Import-Module D:\Users\Jon\Desktop\GitHub\MyPSModules\JFA.MyDevSecret\JFA.MyDevSecret
```

## Credits ##

https://powershellexplained.com/2017-05-27-Powershell-module-building-basics/

_Cheers!_