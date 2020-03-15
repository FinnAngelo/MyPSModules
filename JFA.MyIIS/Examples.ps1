Set-StrictMode -Version latest
cd D:\Users\Jon\Desktop\GitHub\MyPSModules\JFA.MyIIS

Import-Module D:\Users\Jon\Desktop\GitHub\MyPSModules\JFA.MyIIS\JFA.MyIIS -Force

Invoke-Pester -TestName "Explore setting up MyIISWebSite"

#cd IIS:\AppPools
#dir
#cd D:\MyIIS
#dir
cd Cert:\LocalMachine\My
dir
del C1BAD35292F7DACCA1E161A3AE50CECF8EA78112
cd IIS:\Sites
dir
cd IIS:\SslBindings
dir

Get-WebBinding

                $PhysicalPath = "D:\MyIIS"
                $AppName = $AppName
                $Port = 80080
                $SslPort = 80443
                $CertStoreLocation = "Cert:\LocalMachine\My"
                $HostHeader = $AppName+".local"


            $oldCert = Get-ChildItem $CertStoreLocation | Where-Object Subject -eq  "CN=$HostHeader"
            if($oldCert) {
                $oldCert | Remove-Item 
            }

            $AppName = "MyIISWebSite200315171934"

$params = @{
                PhysicalPath = "D:\MyIIS";
                AppName = $AppName;
                Port = 40080;
                SslPort = 80443;
                CertStoreLocation = "Cert:\LocalMachine\";
                HostHeader = $AppName+".local";
                }
            Remove-MyIISWebSite @params

            Remove-Item $webSite.name

    $website = Get-WebSite -Name $AppName
    if($website) {
        Remove-Item $webSite
    }


    New-SelfSignedCertificate -DnsName localhost -CertStoreLocation "Cert:\LocalMachine\My"