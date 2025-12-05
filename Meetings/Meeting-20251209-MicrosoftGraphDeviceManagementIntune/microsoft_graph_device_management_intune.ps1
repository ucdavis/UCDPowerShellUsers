<#
    Title: microsoft_graph_device_management_intune.ps1
    Authors: Dean Bunn and Justin Earley
    Last Edit: 2025-12-09
#>

#Stopping an Accidental Run
Exit;

#Install Required Modules
Install-Module -Name Microsoft.Graph.Authentication,
                     Microsoft.Graph.Users,
                     Microsoft.Graph.Groups,
                     Microsoft.Graph.DeviceManagement -Scope CurrentUser -Repository PSGallery -Force

#View Installed Modules
Get-InstalledModule

#Import Required Modules
Import-Module Microsoft.Graph.Authentication,Microsoft.Graph.Users,Microsoft.Graph.Groups,Microsoft.Graph.DeviceManagement

#View Available Commands in a Module
Get-Command -Module Microsoft.Graph.DeviceManagement

#Connect to Microsoft Graph
Connect-MgGraph

#Disconnect Microsoft Graph Session
Disconnect-MgGraph