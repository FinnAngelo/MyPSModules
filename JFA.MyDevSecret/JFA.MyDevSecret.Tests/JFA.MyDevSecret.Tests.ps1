Describe "Explore Setting Secrets for Powershell Modules" {

    Context "Check setting a secret" {
        It "When Set-MyDevSecret, Then there is a new file" {
            #given
            $secret = "Howdy! I'm a secret!"
            $key = [System.DateTime]::Now.ToString("yyyy-MM-dd+HH-mm-ss-ffff")

            #when
            Set-MyDevSecret $key $secret

            #then
            $result = Test-Path "G:\MyDevSecret\$key.txt"
            $result | Should Be True
        }
    }

    Context "Check getting a secret" {
        It "When Get-MyDevSecret, Then the secret comes from a file" {
            #given
            $key = [System.DateTime]::Now.ToString("yyyy-MM-dd+HH-mm-ss-ffff")        
            $secret = "Howdy! I'm a secret! I was set at $key!"
            Set-MyDevSecret $key $secret

            #when
            $result = Get-MyDevSecret $key

            #then
            $result | Should Be $secret
        }
    }
}