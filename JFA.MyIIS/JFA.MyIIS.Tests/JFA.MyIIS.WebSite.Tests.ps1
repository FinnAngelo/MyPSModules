Set-StrictMode -Version Latest

Describe "Explore setting up MyIISWebSite" {
    Context "Check creating a website" {
        $params = "Undefined"
        BeforeEach {
            $AppName = "MyIISWebSite"+(Get-Date -Format "yyMMddHHmmss")
            $params = @{
                PhysicalPath = "D:\MyIIS";
                AppName = $AppName;
                Port = 80080;
                SslPort = 80443;
                CertStoreLocation = "Cert:\LocalMachine\My";
                HostHeader = $AppName+".local";
                }
            Remove-MyIISWebSite @params
        }

        AfterEach {
            Remove-MyIISWebSite @params
        }

        It "When New-MyIISWebSite, Then there is a new website" {
            #given
            New-MyIISAppPool -AppName $params.AppName
            New-MyCert -CertStoreLocation $params.CertStoreLocation -HostHeader $params.HostHeader
            
            #when
            New-MyIISWebSite @params

            #then
            "$params.PhysicalPath\params.$AppName" | Should Be "jj"
            $result = Test-Path -Path "$params.PhysicalPath\params.$AppName"
            $result | Should Be True
        }        
    }
}