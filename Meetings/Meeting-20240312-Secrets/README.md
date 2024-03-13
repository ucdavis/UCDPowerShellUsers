## Secret Management 

### Resource Links

[Overview of the SecretManagement and SecretStore modules](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview)

[Use the SecretStore in automation](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/how-to/using-secrets-in-automation)


### Setup and Configuration

Find the Secret Management Modules
```powershell
Find-Module -Tag SecretManagement
```
Install Secret Management Modules
```powershell
Install-Module Microsoft.PowerShell.SecretManagement -Repository PSGallery
Install-Module Microsoft.PowerShell.SecretStore -Repository PSGallery
```
Import SecretManagement Modules
```powershell
Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore
```
Setup or View Secret Store Configuration
```powershell
Get-SecretStoreConfiguration
```
Create Default Secret Vault
```powershell
Register-SecretVault -Name "NFLTeams" -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
```
View Vault Information
```powershell
Get-SecretVault
```
Add Secrets
```powershell
Set-Secret -Name "Raiders-QB" -Secret "Gardner Minshew"
Set-Secret -Name "Niners-QB" -Secret "Brock Purdy"
Set-Secret -Name "Chiefs-QB" -Secret "Kermit Mahomes"
```
View Secret
```powershell
Get-Secret -Name "Niners-QB" -AsPlainText
```
Storing Secrets Store Configuration General Password
```powershell
$credential = Get-Credential -UserName 'SecureStore'
$securePasswordPath = 'C:\db\passwd.xml'
$credential.Password |  Export-Clixml -Path $securePasswordPath
```
Change Secrets Store to Have No Interaction and a Longer Timeout
```powershell
Set-SecretStoreConfiguration -Authentication 'Password' -PasswordTimeout 3600 -Interaction 'None'
```
Now that Secrets Store is Locked. Open it with Stored Encrypted Password
```powershell
$password = Import-CliXml -Path $securePasswordPath
Unlock-SecretStore -Password $password
```
Pull Secret and Assign to Variable
```powershell
$raidersQB = Get-Secret -Name 'Raiders-QB' -AsPlainText
Write-Output $raidersQB
```




