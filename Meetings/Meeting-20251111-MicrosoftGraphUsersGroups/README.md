## Micrsoft Graph Users and Groups

Part 2 of series on Microsoft Graph PowerShell SDK usage. This session will cover querying users and groups.

### Resource Links

[Microsoft Azure Portal](https://portal.azure.com/#allservices)

[Microsoft Intune Admin Center](https://intune.microsoft.com/#home)

[Microsoft.Graph.Users Module](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users)

[Microsoft.Graph.Groups Module](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.groups)

[Microsoft Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)

[Intune / Entra Terminology UCD KB](https://kb.ucdavis.edu/?id=10695)


### Module Installation Commands
Install Required Modules
```powershell
Install-Module -Name Microsoft.Graph.Authentication,
                     Microsoft.Graph.Users,
                     Microsoft.Graph.Groups,
                     Microsoft.Graph.DeviceManagement -Scope CurrentUser -Repository PSGallery -Force
```
View Installed Modules
```powershell
Get-InstalledModule 
```
View Available Commands in a Module
```powershell
Get-Command -Module Microsoft.Graph.Users
```
### Module Import and Connection Commands
Import Required Modules
```powershell
Import-Module Microsoft.Graph.Authentication,Microsoft.Graph.Users,Microsoft.Graph.Groups,Microsoft.Graph.DeviceManagement
```
Connect to Microsoft Graph
```powershell
Connect-MgGraph
```
Disconnect Microsoft Graph Session
```powershell
Disconnect-MgGraph
```
### User Commands
View Individual User in our Entra tenant
```powershell
Get-MgUser -UserId "dbunn@ucdavis.edu"
```
View Individual User Full Information
```powershell
Get-MgUser -UserId "benclark@ucdavis.edu" | Format-List
```
View Individual User by UPN
```powershell
Get-MgUserByUserPrincipalName -UserPrincipalName "sapigg@ucdavis.edu"
```
View User's Manager (Only If Set in AD)
```powershell
Get-MgUserManager -UserId "dbunn@ucdavis.edu" | Select-Object -ExpandProperty AdditionalProperties | Format-List
```
View User's Owned Devices
```powershell
Get-MgUserOwnedDevice -UserId "dbunn@ucdavis.edu" | Select-Object -ExpandProperty AdditionalProperties | Format-List
```
View Individual User's On Premise Extension Attributes
```powershell 
Get-MgUser -UserId "dbunn@ucdavis.edu" -Property onPremisesExtensionAttributes | Select-Object -ExpandProperty
onPremisesExtensionAttributes | Format-List
```
Search for All Members with a Specific Last Name
```powershell
Get-MgUser -Search '"Surname:Bunn"' -ConsistencyLevel eventual -All | Format-Table -AutoSize
```
Search for a Specific Member by Mail
```powershell
Get-MgUser -Filter "mail eq 'jeremy@ucdavis.edu'"
```
View Individual User's Group Membership
```powershell
Get-MgUserMemberOf -UserId (Get-MgUser -UserId 'dbunn@ucdavis.edu').Id -All -ConsistencyLevel eventual | ForEach-Object { Get-MgGroup -GroupId $_.Id } | Select-Object Id,DisplayName,Description | Sort-Object DisplayName | Format-Table -AutoSize
#Or
Get-MgUserMemberOfAsGroup -UserId "dbunn@ucdavis.edu" -All -ConsistencyLevel eventual | Sort-Object DisplayName
#Or
Get-MgUserTransitiveMemberOfAsGroup -UserId "dbunn@ucdavis.edu" -All -ConsistencyLevel eventual | Sort-Object DisplayName
```

### Group Commands
View Group by Display Name
```powershell
Get-MgGroup -Filter "displayName eq 'COE-SNG-IT'"
```
View Group by GroupID (Guid) 
```powershell
Get-MgGroup -GroupId "972f8d4f-2ec0-4dc5-8bcb-4432407c1eaa" | Format-List
```
Search for All Groups that Start with a Specific Term
```powershell
Get-MgGroup -Filter "startsWith(displayName, 'LS-')" -ConsistencyLevel eventual -All
```
View All Direct Members of a Specific Group
```powershell
Get-MgGroupMember -GroupId (Get-MgGroup -Filter "displayName eq 'COE-US-IT'").Id -All -ConsistencyLevel eventual | ForEach-Object { Get-MgUser -UserId $_.Id } | Format-Table -AutoSize
#Or
Get-MgGroupMemberAsUser -GroupId (Get-MgGroup -Filter "displayName eq 'COE-US-IT'").Id -All -ConsistencyLevel eventual | Sort-Object DisplayName | Format-Table -AutoSize
```
Get Count of Group Membership
```powershell
Get-MgGroupMemberCount -GroupId (Get-MgGroup -Filter "displayName eq 'COE-SNG-IT'").Id -ConsistencyLevel eventual
```
Get Count of Group's Member Of
```powershell
Get-MgGroupMemberOfCount -GroupId (Get-MgGroup -Filter "displayName eq 'COE-SNG-IT'").Id -ConsistencyLevel eventual
```
