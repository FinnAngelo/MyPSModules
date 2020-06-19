Set-StrictMode -Version Latest

# ---------------------------------------------------
# Best Practice HelloWorld
# https://poshcode.gitbooks.io/powershell-practice-and-style/Style-Guide/Function-Structure.html

function Get-MyHelloWorld {
	[CmdletBinding()]
	[OutputType([string])]
	param (
		[Parameter(Mandatory = $true,
			ValueFromPipelineByPropertyName = $true,
			Position = 0)]
		[DateTime]$now
	)
	process {
		$deCultureInfo = New-Object System.Globalization.CultureInfo("de-DE")
		$result = "Hello World on " + $now.ToString("f", $deCultureInfo)

		$result
	}
}

# ---------------------------------------------------
# Make the Module Manifest
# https://powershellexplained.com/2017-05-27-Powershell-module-building-basics/
# https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Core/New-ModuleManifest?view=powershell-7
function New-MyAzAdventureWorksModuleManifest {
	[CmdletBinding()]
	param ()
	process {
		$version = @{
			Major = [string]0
			Minor = [string](([datetime]::Today).Year - 2000) + [string]([datetime]::Today).DayOfYear
			Patch = [int][datetime]::Now.TimeOfDay.TotalMinutes
		}
		$manifest = @{
			Path          = '.\JFA.MyAzAdventureWorks\JFA.MyAzAdventureWorks.psd1'
			RootModule    = 'JFA.MyAzAdventureWorks.psm1'
			Author        = 'Jon Finn Angelo'

			ModuleVersion = $version.Major + "." + $version.Minor + "." + $version.Patch
		}

		$oldManifestPath = ".\JFA.MyAzAdventureWorks\JFA.MyAzAdventureWorks.psd1"
		If (Test-Path $oldManifestPath) {
			Remove-Item $oldManifestPath
		}
		New-ModuleManifest @manifest
	}
}

