Set-StrictMode -Version Latest
#https://docs.microsoft.com/en-us/powershell/module/iisadministration/new-iissitebinding?view=win10-ps
Describe "Explore setting up an IIS Server" {
    Context "Check SelfSigning Certs" {
        $CertStoreLocation = "Cert:\LocalMachine\My"
        $HostHeader = "Undefined"
        BeforeEach {
            $HostHeader = "SelfSignedCert"+(Get-Date -Format "yyMMddHHmmss")
            $oldCert = Get-ChildItem $CertStoreLocation | Where-Object Subject -eq  "CN=$HostHeader"
            if($oldCert) {
                $oldCert | Remove-Item 
            }
        }

        AfterEach {
                Get-ChildItem $CertStoreLocation | Where-Object Subject -eq  "CN=$HostHeader" | Remove-Item
        }

        It "When New-MyCert, Then there is a new Cert" {
            #given
            #$AppName = "ImAFolder"
            
            #when
            New-MyCert -CertStoreLocation $CertStoreLocation -HostHeader $HostHeader

            #then
            $result = Get-ChildItem $CertStoreLocation | Where-Object Subject -eq  "CN=$HostHeader"
            $result | Should Not Be $null
        }        
    }
}