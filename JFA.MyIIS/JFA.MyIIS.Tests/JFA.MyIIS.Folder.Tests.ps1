Set-StrictMode -Version Latest

Describe "Explore setting up an IIS Server" {
    Context "Check creating folders" {
        $PhysicalPath = "D:\MyIIS"
        $AppName = "Undefined"
        BeforeEach {
            $AppName = "IISFolder"+(Get-Date -Format "yyMMddHHmmss")
            if (Test-Path -Path "$PhysicalPath\$AppName") {
                Remove-Item -Path "$PhysicalPath\$AppName" -Recurse -Force
            }
        }

        AfterEach {
                Remove-Item -Path "$PhysicalPath\$AppName" -Recurse -Force
        }

        It "When New-MyIISFolders, Then there is a new folder" {
            #given
            #$AppName = "ImAFolder"
            
            #when
            New-MyIISFolders -PhysicalPath $PhysicalPath -AppName $AppName

            #then
            $result = Test-Path -Path "$PhysicalPath\$AppName"
            $result | Should Be True
        }
        
        It "When New-MyIISFolderPermissions, Then the new folder has permissions" {
            #given
            New-MyIISAppPool -AppName $AppName
            New-MyIISFolders -PhysicalPath $PhysicalPath -AppName $AppName
            
            #when
            New-MyIISFolderPermissions -PhysicalPath $PhysicalPath -AppName $AppName

            #then
            $acl = (Get-Acl "$PhysicalPath\$AppName")
            $acl | Should Be "System.Security.AccessControl.DirectorySecurity"
            $rule = $acl.Access | Where-Object { $_.IdentityReference -eq "IIS APPPOOL\$AppName" }
            $rule | Should Be "System.Security.AccessControl.FileSystemAccessRule"
            $rule.AccessControlType | Should Be "Allow"
            $rule.FileSystemRights | Should Be "FullControl"
            $rule.PropagationFlags | Should Be "None"
            $rule.InheritanceFlags | Should Be "ContainerInherit, ObjectInherit"
        }
    }
}