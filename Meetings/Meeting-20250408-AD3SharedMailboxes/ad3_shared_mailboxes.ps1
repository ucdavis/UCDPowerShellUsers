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
Get-EXOMailbox -Identity "dbunn@ucdavis.edu" -PropertySets All

#Show Mailbox Custom and Delivery Settings
Get-EXOMailbox -Identity "dbunn@ucdavis.edu" -PropertySets Custom,Delivery

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

#Show Mailbox Statistics 
Get-EXOMailboxStatistics -Identity "dbunn@ucdavis.edu" -PropertySets All

#Show Mailbox Permissions
Get-EXOMailboxPermission -Identity "dbunn@ucdavis.edu"

#Show Mailbox Folder Permissions
Get-EXOMailboxFolderPermission -Identity "dbunn@ucdavis.edu:\Calendar"

#Show Mobile Devices for User Account
Get-EXOMobileDeviceStatistics -Mailbox "dbunn@ucdavis.edu"



