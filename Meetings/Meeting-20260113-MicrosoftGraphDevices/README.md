## Micrsoft Graph Device Management (Intune)

Part 4 of series on Microsoft Graph PowerShell SDK usage. This session will cover directory management module.

### Resource Links

[Microsoft Azure Portal](https://portal.azure.com/#allservices)

[Microsoft.Graph.Identity.DirectoryManagement Module](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.identity.directorymanagement)

[Microsoft Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)

[Intune / Entra Terminology UCD KB](https://kb.ucdavis.edu/?id=10695)


### Module Installation Commands
Install Required Modules
```powershell
Install-Module -Name Microsoft.Graph.Authentication,
                     Microsoft.Graph.Users,
                     Microsoft.Graph.Groups,
                     Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser -Repository PSGallery -Force
```
View Installed Modules
```powershell
Get-InstalledModule 
```
View Available Commands in a Module
```powershell
Get-Command -Module Microsoft.Graph.DeviceManagement
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