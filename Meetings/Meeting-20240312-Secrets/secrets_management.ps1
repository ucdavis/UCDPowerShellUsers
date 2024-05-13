<#
    Title: secrets_management.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-03-12
#>

#Stopping an Accidental Run
exit

#Find the SecretManagement Modules
Find-Module -Tag SecretManagement

#Install SecretManagement Modules
Install-Module Microsoft.PowerShell.SecretManagement -Repository PSGallery
Install-Module Microsoft.PowerShell.SecretStore -Repository PSGallery

#Import SecretManagement Modules
Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

#Setup or View Secret Store Configuration
Get-SecretStoreConfiguration

#Create Default Secret Vault
Register-SecretVault -Name "NFLTeams" -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

#View Vault Information
Get-SecretVault

#Add Secrets
Set-Secret -Name "Raiders-QB" -Secret "Gardner Minshew"
Set-Secret -Name "Niners-QB" -Secret "Brock Purdy"
Set-Secret -Name "Chiefs-QB" -Secret "Kermit Mahomes"

#View Secret
Get-Secret -Name "Niners-QB" -AsPlainText

#View Secrets Info
Get-SecretInfo -Name *

#Storing Secrets Store Configuration General Password
$credential = Get-Credential -UserName 'SecureStore'
$securePasswordPath = 'C:\db\passwd.xml'
$credential.Password |  Export-Clixml -Path $securePasswordPath

#Change Secrets Store to Have No Interaction and a Longer Timeout
Set-SecretStoreConfiguration -Authentication 'Password' -PasswordTimeout 3600 -Interaction 'None'

#Now that Secrets Store is Locked. Open it with Stored Encrypted Password
$password = Import-CliXml -Path $securePasswordPath
Unlock-SecretStore -Password $password

#Pull Secret and Assign to Variable
$raidersQB = Get-Secret -Name 'Raiders-QB' -AsPlainText
Write-Output $raidersQB

