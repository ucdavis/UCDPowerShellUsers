<#
    Title: ad3_shared_mailboxes.ps1
    Authors: Dean Bunn
    Inspired By: Ben Clark
    Last Edit: 2025-03-07
#>

#Command Reference Only Script. Stopping an Accidental Run
exit;

#Import Exchange Online Management Module. See "commands_for_required_module.ps1" If Not Installed
Import-Module -Name ExchangeOnlineManagement

#Connect to Exchange Online
Connect-ExchangeOnline

#Show Connection Information
Get-ConnectionInformation

#Close Connection (Run When Done Working with Exchange)
Disconnect-ExchangeOnline

#Show Mailbox Information
Get-EXOMailbox -Identity "ncode@ucdavis.edu" -PropertySets All

#Show Mailbox Custom and Delivery Settings
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

#Show Mailbox Statistics (Including Last Login Time)
Get-EXOMailboxStatistics -Identity "ncode@ucdavis.edu" -PropertySets All

#Show Mailbox Permissions
Get-EXOMailboxPermission -Identity "ncode@ucdavis.edu"

#Show Mailbox Folder Permissions
Get-EXOMailboxFolderPermission -Identity "ncode@ucdavis.edu:\Calendar"

#Show Mobile Devices for User Account
Get-EXOMobileDeviceStatistics -Mailbox "ncode@ucdavis.edu"

#Show Send-As Rights for Mailbox
Get-EXORecipientPermission -Identity "ncode@ucdavis.edu"

#Show Distribution Group
Get-DistributionGroup -Identity "coe-ncode-mbx@ad3.ucdavis.edu"

###############################
#Configuring a Shared Mailbox
###############################

#Configure Mailbox to Shared and Sent-As Message Copy
Set-Mailbox -Identity "ncode@ucdavis.edu" -Type shared -MessageCopyForSentAsEnabled $True

#Grant Full Mailbox Access to Distribution Group
Add-MailboxPermission -Identity "ncode@ucdavis.edu" -User "coe-ncode-mbx@ad3.ucdavis.edu" -AccessRights FullAccess

#Remove Full Mailbox Access to Distribution Group
Remove-MailboxPermission -Identity "ncode@ucdavis.edu" -User "coe-ncode-mbx@ad3.ucdavis.edu" -AccessRights FullAccess

#Grant Send-As Rights to Distribution Group
Add-RecipientPermission -Identity "ncode@ucdavis.edu" -Trustee "coe-ncode-mbx@ad3.ucdavis.edu" -AccessRights SendAs

