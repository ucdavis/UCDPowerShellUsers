## Micrsoft Graph SDK Setup

Part 1 of series on Microsoft Graph PowerShell SDK usage. This session will cover setting up the SDK and some basic query commands.

### Resource Links

- [Overview of Microsoft Graph](https://learn.microsoft.com/en-us/graph/overview)
- [Microsoft Graph PowerShell overview](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0)
- [Install the Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0)
- [Authentication module cmdlets in Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0)
- [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)
- [Use query parameters to customize PowerShell query outputs](https://learn.microsoft.com/en-us/powershell/microsoftgraph/use-query-parameters?view=graph-powershell-1.0)
- [Advanced query capabilities on Microsoft Entra ID objects](https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=powershell)

### Setup and Connection Commands

Installing Microsoft Graph Module for All Users
```powershell
Install-Module Microsoft.Graph -Scope AllUsers -Repository PSGallery -Force
```
Installing Microsoft Graph Module for Current User Only
```powershell
Install-Module Microsoft.Graph -Repository PSGallery -Force
```
View Installed Modules
```powershell
Get-InstalledModule
```
View Only Installed Microsoft Graph Modules
```powershell
Get-InstalledModule | Where-Object { $_.Name -Like "Microsoft.Graph.*" } | Select-Object Name
```
View Commands Listed Specific Microsoft Graph Module
```powershell
Get-Command -Module Microsoft.Graph.DeviceManagement 
```
Import Module into Current PowerShell Session
```powershell
Import-Module Microsoft.Graph 
```
Import Only Specific Microsoft Graph Modules
```powershell
Import-Module "Microsoft.Graph.Authentication","Microsoft.Graph.Users","Microsoft.Graph.DeviceManagement","Microsoft.Graph.Groups"
```
View All Microsoft Graph Commands that the Related API URI has Search Term 
```powershell
Find-MgGraphCommand -Uri .*device* | Format-Table -AutoSize
```
Connect to Microsoft Graph (Will Open a Browser Window or Use Most Current Browser Session)
```powershell
Connect-MgGraph
```
Get Microsoft Graph Session Details
```powershell
Get-MgContext
```
View Assigned Scopes for Session
```powershell
(Get-MgContext).Scopes
```
Disconnect Microsoft Graph Session
```powershell
Disconnect-MgGraph
```

