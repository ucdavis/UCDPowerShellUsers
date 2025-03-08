<#
    Title: commands_for_required_module.ps1
    Authors: Dean Bunn
    Last Edit: 2025-03-07
#>

#Command Reference Only Script. Stopping an Accidental Run
exit;

#Install Exchange Online Management Module for All Users
Install-Module -Name ExchangeOnlineManagement

#Install Exchange Online Management Module for Current User Only
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser

#Update Exchange Online Management Module for All Users
Update-Module -Name ExchangeOnlineManagement 

#Update Exchange Online Management Module for Current User Install
Update-Module -Name ExchangeOnlineManagement -Scope CurrentUser

#Get Installed Module Information
Get-InstalledModule -Name ExchangeOnlineManagement
