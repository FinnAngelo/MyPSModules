Set-StrictMode -Version Latest

#Requires -Modules PKI
#Requires -Modules IISAdministration
#Requires -Modules WebAdministration

# ---------------------------------------------------
# AppPool
function New-MyIISAppPool {
	param(
		[Parameter(Mandatory)]
        [string] $AppName
	) 
    Write-Debug("New-MyIISAppPool : $AppName")

    if(Test-Path -Path "IIS:\AppPools\$AppName")
    {
        Remove-WebAppPool -Name $AppName
    }

    New-Item -Path "IIS:\AppPools" -Name "$AppName" -Type AppPool
    Set-ItemProperty -Path "IIS:\AppPools\$AppName" -name "managedRuntimeVersion" -value "v4.0"
    Set-ItemProperty -Path "IIS:\AppPools\$AppName" -name "enable32BitAppOnWin64" -value $false
    Set-ItemProperty -Path "IIS:\AppPools\$AppName" -name "autoStart" -value $true
    Set-ItemProperty -Path "IIS:\AppPools\$AppName" -name "processModel" -value @{identitytype="ApplicationPoolIdentity"}
    Set-ItemProperty -Path "IIS:\AppPools\$AppName" -name "managedPipelineMode" -value 0 # This is Classic (vs Integrated=0) Mode  
}

# ---------------------------------------------------
# Folders and Permissions
function New-MyIISFolders {
    param(
		[Parameter(Mandatory)]
        [string] $PhysicalPath,
		[Parameter(Mandatory)]
        [string] $AppName
	) 
    Write-Debug("New-MyIISFolders : $PhysicalPath $AppName")

    # Setup Website Physical Path
    if (Test-Path -Path "$PhysicalPath\$AppName") {
        Remove-Item -Path "$PhysicalPath\$AppName" -Recurse -Force
    }
    New-Item -ItemType directory -Path "$PhysicalPath\$AppName"
}
# Applies FullControl permissions to user of WebAppPool 
#   i.e. ApplicationPoolIdentity 
#   i.e. `IIS AppPool\$AppName`
#   i.e. `IIS AppPool\TRASHME`
#   This is overpermissioned for a website, and needs refinement
function New-MyIISFolderPermissions {	
    param(
		[Parameter(Mandatory)]
        [string] $PhysicalPath,
		[Parameter(Mandatory)]
        [string] $AppName
	) 
    Write-Debug("New-MyIISFolderPermissions : $PhysicalPath $AppName")

    $Acl = Get-Acl "$PhysicalPath\$AppName"
    $Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("IIS APPPOOL\$AppName","FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.SetAccessRule($Ar)
    Set-Acl "$PhysicalPath\$AppName" $Acl
}

# ---------------------------------------------------
# SelfSigned Certs
function Remove-MyCert {
    param(
		[Parameter(Mandatory)]
        [string] $CertStoreLocation,
		[Parameter(Mandatory)]
        [string] $HostHeader
	) 
    Write-Debug("Remove-MyCert : $CertStoreLocation $HostHeader")

	$oldCert = Get-ChildItem $CertStoreLocation | Where-Object Subject -eq  "CN=$HostHeader"
	if($oldCert) {
		$oldCert | Remove-Item 
	}
}

function New-MyCert {
    param(
		[Parameter(Mandatory)]
        [secureString] $Password,
		[Parameter(Mandatory)]
        [string] $HostHeader
	) 
    Write-Debug("New-MyCert : $CertStoreLocation $HostHeader")

$myCertStoreLocation = "Cert:\LocalMachine\My"
$rootCertStoreLocation = "Cert:\LocalMachine\Root"

$certificate = New-SelfSignedCertificate -DnsName $HostHeader -CertStoreLocation $myCertStoreLocation

$certificatePath = ($myCertStoreLocation + $certificate.Thumbprint)

$tempFile = New-TemporaryFile

Export-PfxCertificate -FilePath $tempFile.FullName -Cert $certificatePath -Password $Password
Import-PfxCertificate -FilePath $tempFile.FullName -CertStoreLocation "Cert:\LocalMachine\Root" -Password $Password
Remove-Item $newFile.FullName -Force

}
# ---------------------------------------------------
# SelfSigned Certs

function Remove-MyIISWebSite {
    param(
		[Parameter(Mandatory)]
        [string] $PhysicalPath,
		[Parameter(Mandatory)]
        [string] $AppName,
		[Parameter(Mandatory)]
        [int] $Port,
		[Parameter(Mandatory)]
        [int] $SslPort,
		[Parameter(Mandatory)]
        [string] $CertStoreLocation,
		[Parameter(Mandatory)]
        [string] $HostHeader
	)
    Write-Debug("Remove-MyIISWebSite : $PhysicalPath $AppName $Port $SslPort $CertStoreLocation $HostHeader")
    
    $sslPortBinding = Get-WebBinding | Where-Object bindingInformation -EQ "*:${SslPort}:$HostHeader"
    if($sslPortBinding) {
        Remove-WebBinding -InputObject $sslPortBinding 
    }
    $website = Get-WebSite -Name $AppName
    if($website) {
        Remove-Item $webSite
    }
}
function New-MyIISWebSite {
    param(
		[Parameter(Mandatory)]
        [string] $PhysicalPath,
		[Parameter(Mandatory)]
        [string] $AppName,
		[Parameter(Mandatory)]
        [int] $Port,
		[Parameter(Mandatory)]
        [int] $SslPort,
		[Parameter(Mandatory)]
        [string] $CertStoreLocation,
		[Parameter(Mandatory)]
        [string] $HostHeader
	) 
    Write-Debug("New-MyIISWebSite : $PhysicalPath $AppName $Port $SslPort $CertStoreLocation $HostHeader")

    $params = @{
        PhysicalPath = $PhysicalPath;
        AppName = $AppName;
        Port = $Port;
        SslPort = $SslPort;
        CertStoreLocation = $CertStoreLocation;
        HostHeader = $HostHeader;
    }
    Remove-MyIISWebSite @params
    
    New-WebSite -Name $AppName -Port $Port -PhysicalPath "$PhysicalPath\$AppName" -ApplicationPool "$AppName" -Force
    Restart-WebAppPool $AppName
    Stop-Website -Name $AppName
    Start-Website -Name $AppName

    # Only add SSL if the cert exists
    $myCert = Get-ChildItem $CertStoreLocation | Where-Object Subject -eq  "CN=$HostHeader"
    if (!$myCert) {
        New-WebBinding -Name $AppName -Protocol https -Port $SslPort -HostHeader $HostHeader -SslFlags 1
        $binding=Get-WebBinding -Name $AppName -Port $SslPort  -HostHeader $HostHeader
        $binding.AddSslCertificate($myCert.GetCertHashString(), "My")
    }
}

#---------------------------------------
#https://blog.ukotic.net/2017/08/15/could-not-establish-trust-relationship-for-the-ssltls-invoke-webrequest/
function Ignore-ServerCertificateValidation() {
    if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
    {
    $certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
        Add-Type $certCallback
    }
    [ServerCertificateValidationCallback]::Ignore()
}
#---------------------------------------