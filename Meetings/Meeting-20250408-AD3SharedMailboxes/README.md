## AD3 Shared Mailboxes

Commands for working with Shared Mailboxes in AD3 

### Requirements

- The ExchangeOnlineManagement module installed. See [Commands for Required Module](commands_for_required_module.ps1) script for installation commands
- The account running the shell session must be in one of the uConnect RBAC "\<dept\>-MSGADMINS" groups

### Connect to Exchange Online

Import Exchange Online Management Module and Connect
```powershell
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline
```
Show Connection Information
```powershell
Get-ConnectionInformation
```
Close Connection (Run When Done Working with Exchange)
```powershell
Disconnect-ExchangeOnline
```

### Displaying Exchange Item Information

Show Mailbox Information
```powershell
Get-EXOMailbox -Identity "ncode@ucdavis.edu" -PropertySets All
```
Show Mailbox Custom and Delivery Settings
```powershell
Get-EXOMailbox -Identity "ncode@ucdavis.edu" -PropertySets Custom,Delivery
#Mailbox Property Sets
<#
All
Minimum
AddressList
Archive
Custom
Delivery
Moderation
Policy
Quota
Retention
#>
```
Show Mailbox Statistics (Including Last Login Time)
```powershell
Get-EXOMailboxStatistics -Identity "ncode@ucdavis.edu" -PropertySets All
```
Show Mailbox Permissions
```powershell
Get-EXOMailboxPermission -Identity "ncode@ucdavis.edu"
```
Show Mailbox Folder Permissions
```powershell
Get-EXOMailboxFolderPermission -Identity "ncode@ucdavis.edu:\Calendar"
```
Show Mobile Devices for User Account
```powershell
Get-EXOMobileDeviceStatistics -Mailbox "ncode@ucdavis.edu"
```
Show Send-As Rights for Mailbox
```powershell
Get-EXORecipientPermission -Identity "ncode@ucdavis.edu"
```
Show Distribution Group
```powershell
Get-DistributionGroup -Identity "coe-ncode-mbx@ad3.ucdavis.edu"
```
### Configuring a Shared Mailbox

Configure Mailbox to Shared
```powershell
Set-Mailbox -Identity "ncode@ucdavis.edu" -Type shared
```
Set Sent-As Message Copy
```powershell
Set-Mailbox -Identity "ncode@ucdavis.edu" -MessageCopyForSentAsEnabled $True
```
Grant Full Mailbox Access to Distribution Group
```powershell
Add-MailboxPermission -Identity "ncode@ucdavis.edu" -User "coe-ncode-mbx@ad3.ucdavis.edu" -AccessRights FullAccess
```
Remove Full Mailbox Access to Distribution Group
```powershell
Remove-MailboxPermission -Identity "ncode@ucdavis.edu" -User "coe-ncode-mbx@ad3.ucdavis.edu" -AccessRights FullAccess
```
Grant Send-As Rights to Distribution Group
```powershell
#Add-RecipientPermission -Identity "ncode@ucdavis.edu" -Trustee "coe-ncode-mbx@ad3.ucdavis.edu" -AccessRights SendAs
#Currently not working. Need to work with uConnect admins on the issue
```
