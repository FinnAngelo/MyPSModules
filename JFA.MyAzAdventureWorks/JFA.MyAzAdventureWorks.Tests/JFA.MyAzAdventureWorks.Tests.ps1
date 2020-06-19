Set-StrictMode -Version Latest
Import-Module .\JFA.MyAzAdventureWorks

Describe "Explore Setting up an AdventureWorks Db on Azure" {

    Context "Check MyHelloWorld for best practices" {
        It "When Get-MyHelloWorld, Then there is a German formated date" {
            #given
            [DateTime]$nowz = New-Object DateTime 2020, 07, 02, 12, 30, 0

            #when
            $result = Get-MyHelloWorld -now $nowz

            #then
            $result | Should Be "Hello World on Donnerstag, 2. Juli 2020 12:30"
        }
    }
}