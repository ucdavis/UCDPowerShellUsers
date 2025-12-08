<#
    Title: microsoft_graph_directory_management.ps1
    Authors: Dean Bunn and Justin Earley
    Last Edit: 2026-01-13
#>

#Stopping an Accidental Run
Exit;

#Install Required Modules
Install-Module -Name Microsoft.Graph.Authentication,
                     Microsoft.Graph.Users,
                     Microsoft.Graph.Groups,
                     Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser -Repository PSGallery -Force

#View Installed Modules
Get-InstalledModule

#Import Required Modules
Import-Module Microsoft.Graph.Authentication,Microsoft.Graph.Users,Microsoft.Graph.Groups,Microsoft.Graph.Identity.DirectoryManagement

#View Available Commands in a Module
Get-Command -Module Microsoft.Graph.Identity.DirectoryManagement

#Connect to Microsoft Graph
Connect-MgGraph

#Disconnect Microsoft Graph Session
Disconnect-MgGraph




#View Device's Group Membership
Get-MgDeviceMemberOf -DeviceId (Get-MgDevice -Filter "displayName eq 'COE-J238H03'").Id | Foreach-Object { Get-MgGroup -GroupId $_.Id }