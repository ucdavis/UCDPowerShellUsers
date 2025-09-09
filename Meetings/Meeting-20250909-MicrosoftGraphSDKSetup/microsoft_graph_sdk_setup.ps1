<#
    Title: microsoft_graph_sdk_setup.ps1
    Authors: Justin Earley and Dean Bunn
    Last Edit: 2025-09-09
#>

#Stopping an Accidental Run
Exit;

#Installing Microsoft Graph Module for All Users
Install-Module Microsoft.Graph -Scope AllUsers -Repository PSGallery -Force

#Installing Microsoft Graph Module for Current User Only
Install-Module Microsoft.Graph -Repository PSGallery -Force

#View Installed Modules
Get-InstalledModule

#View Only Installed Microsoft Graph Modules
Get-InstalledModule | Where-Object { $_.Name -Like "Microsoft.Graph.*" } | Select-Object Name

#View Commands Listed Specific Microsoft Graph Module
Get-Command -Module Microsoft.Graph.DeviceManagement 

#View All Microsoft Graph Commands that the Related API URI has Search Term 
Find-MgGraphCommand -Uri .*device* | Format-Table -AutoSize

#Import Module into Current PowerShell Session
Import-Module Microsoft.Graph 

#Import Only Specific Microsoft Graph Modules
Import-Module "Microsoft.Graph.Authentication","Microsoft.Graph.Users","Microsoft.Graph.DeviceManagement","Microsoft.Graph.Groups"

#Connect to Microsoft Graph (Will Open a Browser Window or Use Most Current Browser Session)
Connect-MgGraph

#Disconnect Microsoft Graph Session
Disconnect-MgGraph

#Get Microsoft Graph Session Details
Get-MgContext

#View Assigned Scopes for Session
(Get-MgContext).Scopes


#Get-MgUser -Search '"Surname:Bunn"' -ConsistencyLevel eventual -All | Format-Table -AutoSize

#Get-MgUser -UserId "dbunn@ucdavis.edu" -Property onPremisesExtensionAttributes | Select -ExpandProperty onPremisesExtensionAttributes | Format-List

#Get-MgGroupMember -GroupId (Get-MgGroup -Filter "displayName eq 'COE-US-IT'").Id | ForEach-Object { Get-MgUser -UserId $_.Id } | Format-Table -AutoSize

#Get-MgUserMemberOf -UserId (Get-MgUser -UserId 'dbunn@ucdavis.edu').Id -All | ForEach-Object { Get-MgGroup -GroupId $_.Id } | Select-Object Id,DisplayName,Description | Sort-Object DisplayName | Format-Table -AutoSize