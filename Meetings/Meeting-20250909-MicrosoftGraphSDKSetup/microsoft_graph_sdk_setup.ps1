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

#Import Module into Current PowerShell Session
Import-Module Microsoft.Graph 

#Import Only Specific Microsoft Graph Modules
Import-Module "Microsoft.Graph.Authentication","Microsoft.Graph.Users","Microsoft.Graph.DeviceManagement","Microsoft.Graph.Groups"

#View All Microsoft Graph Commands that the Related API URI has Search Term 
Find-MgGraphCommand -Uri .*device* | Format-Table -AutoSize

#Connect to Microsoft Graph (Will Open a Browser Window or Use Most Current Browser Session)
Connect-MgGraph

#Get Microsoft Graph Session Details
Get-MgContext

#View Assigned Scopes for Session
(Get-MgContext).Scopes

#Disconnect Microsoft Graph Session
Disconnect-MgGraph
