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
                     Microsoft.Graph.DeviceManagement,
                     Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser -Repository PSGallery -Force

#View Installed Modules
Get-InstalledModule

#Import Required Modules
Import-Module Microsoft.Graph.Authentication,Microsoft.Graph.Users,Microsoft.Graph.Groups,Microsoft.Graph.Identity.DirectoryManagement,Microsoft.Graph.DeviceManagement

#View Available Commands in a Module
Get-Command -Module Microsoft.Graph.DeviceManagement

#Connect to Microsoft Graph
Connect-MgGraph

#Disconnect Microsoft Graph Session
Disconnect-MgGraph

#View All Commands Related to Managed Devices in Device Management Module
Get-Help -Name MgDeviceManagementManagedDevice | Select-Object -Property Name,Synopsis | Format-Table -AutoSize

#View Managed Devices
Get-MgDeviceManagementManagedDevice -Top 10 # View Only First 10
# Or use -All for View All Devices
# Get-MgDeviceManagementManagedDevice -All

#View Managed Device by ID
Get-MgDeviceManagementManagedDevice -ManagedDeviceId "76342a17-8e24-4cfc-a7ee-ddd939d92076" | Format-List

#View Managed Devices with Name that Starts with Specific Characters
Get-MgDeviceManagementManagedDevice -Filter "startswith(deviceName,'coe-')" | Format-Table -AutoSize





#View Device's Group Membership
Get-MgDeviceMemberOf -DeviceId (Get-MgDevice -Filter "displayName eq 'COE-J238H03'").Id | Foreach-Object { Get-MgGroup -GroupId $_.Id }