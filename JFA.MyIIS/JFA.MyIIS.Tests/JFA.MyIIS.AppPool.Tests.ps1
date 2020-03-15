Set-StrictMode -Version Latest

Describe "Explore setting up an IIS Server" {
    Context "Check creating an AppPool" {
        $AppName = "Undefined"
        BeforeEach {
            $AppName = "AppPoolName"+(Get-Date -Format "yyMMddHHmmss")
            if(Test-Path -Path "IIS:\AppPools\$AppName")
            {
                Remove-WebAppPool -Name $AppName
            }
        }

        AfterEach {
                Remove-WebAppPool -Name $AppName
        }

        It "When New-MyIISAppPool, Then there is a new Application Pool" {
            #given
            #$AppName = "ImATestAppPool"
            
            #when
            New-MyIISAppPool -AppName $AppName

            #then
            $result = Test-Path -Path "IIS:\AppPools\$AppName"
            $result | Should Be True
        }
    }
}