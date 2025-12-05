<#
    Title: microsoft_graph_users_and_groups.ps1
    Authors: Dean Bunn and Justin Earley
    Last Edit: 2025-11-11
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
Get-Command -Module Microsoft.Graph.Users

#Connect to Microsoft Graph
Connect-MgGraph

#Disconnect Microsoft Graph Session
Disconnect-MgGraph

#View Individual User in our Entra tenant 
Get-MgUser -UserId "dbunn@ucdavis.edu"

#View Individual User Full Information
Get-MgUser -UserId "benclark@ucdavis.edu" | Format-List 

#View Individual User by UPN
Get-MgUserByUserPrincipalName -UserPrincipalName "sapigg@ucdavis.edu"

#View User's Manager (Only If Set in AD)
Get-MgUserManager -UserId "dbunn@ucdavis.edu" | Select-Object -ExpandProperty AdditionalProperties | Format-List 

#View User's Owned Devices
Get-MgUserOwnedDevice -UserId "dbunn@ucdavis.edu" | Select-Object -ExpandProperty AdditionalProperties | Format-List

#View Individual User's On Premise Extension Attributes 
Get-MgUser -UserId "dbunn@ucdavis.edu" -Property onPremisesExtensionAttributes | Select-Object -ExpandProperty onPremisesExtensionAttributes | Format-List

#Search for All Members with a Specific Last Name
Get-MgUser -Search '"Surname:Bunn"' -ConsistencyLevel eventual -All | Format-Table -AutoSize

#Search for a Specific Member by Mail 
Get-MgUser -Filter "mail eq 'jeremy@ucdavis.edu'" 

#View Individual User's Group Membership
Get-MgUserMemberOf -UserId (Get-MgUser -UserId 'dbunn@ucdavis.edu').Id -All -ConsistencyLevel eventual | ForEach-Object { Get-MgGroup -GroupId $_.Id } | Select-Object Id,DisplayName,Description | Sort-Object DisplayName | Format-Table -AutoSize
#Or
Get-MgUserMemberOfAsGroup -UserId "dbunn@ucdavis.edu" -All -ConsistencyLevel eventual | Sort-Object DisplayName
#Or
Get-MgUserTransitiveMemberOfAsGroup -UserId "dbunn@ucdavis.edu" -All -ConsistencyLevel eventual | Sort-Object DisplayName

#View Group by Display Name
Get-MgGroup -Filter "displayName eq 'COE-SNG-IT'" 

#View Group by GroupID (Guid) 
Get-MgGroup -GroupId "972f8d4f-2ec0-4dc5-8bcb-4432407c1eaa" | Format-List

#Search for All Groups that Start with a Specific Term
Get-MgGroup -Filter "startsWith(displayName, 'LS-')" -ConsistencyLevel eventual -All

#View All Direct Members of a Specific Group
Get-MgGroupMember -GroupId (Get-MgGroup -Filter "displayName eq 'COE-US-IT'").Id -All -ConsistencyLevel eventual | ForEach-Object { Get-MgUser -UserId $_.Id } | Format-Table -AutoSize
#Or
Get-MgGroupMemberAsUser -GroupId (Get-MgGroup -Filter "displayName eq 'COE-US-IT'").Id -All -ConsistencyLevel eventual | Sort-Object DisplayName | Format-Table -AutoSize

#Get Count of Group Membership
Get-MgGroupMemberCount -GroupId (Get-MgGroup -Filter "displayName eq 'COE-SNG-IT'").Id -ConsistencyLevel eventual

#Get Count of Group's Member Of
Get-MgGroupMemberOfCount -GroupId (Get-MgGroup -Filter "displayName eq 'COE-SNG-IT'").Id -ConsistencyLevel eventual