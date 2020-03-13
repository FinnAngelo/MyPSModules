Set-StrictMode -Version Latest

# ---------------------------------------------------
# User Secrets
# http://www.finnangelo.com/powershell/2020/02/02/Powershell_Secrets.html

function Set-MyDevSecret([String] $key, [String] $secret) {
    $filePath = "G:\MyDevSecret\$key.txt"
    $secureString = $secret | ConvertTo-SecureString -AsPlainText -Force 
    $secureStringText = $secureString | ConvertFrom-SecureString

    New-Item -Path $filePath -Type file -Force
    Set-Content -Path $filePath -Value $secureStringText
}

function Set-MyDevSecretFromSecureString([String] $key, [secureString] $secureSecret) {
    $filePath = "G:\MyDevSecret\$key.txt"

    $secureStringText = $secureSecret | ConvertFrom-SecureString

    New-Item -Path $filePath -Type file -Force
    Set-Content -Path $filePath -Value $secureStringText
}

function Get-MyDevSecret($key) {  
    $filePath = "G:\MyDevSecret\$key.txt"
    $secureStringText = Get-Content $filePath
    $secureString = $secureStringText | ConvertTo-SecureString
    $secret = (New-Object PSCredential "user", $secureString).GetNetworkCredential().Password
    return $secret
}