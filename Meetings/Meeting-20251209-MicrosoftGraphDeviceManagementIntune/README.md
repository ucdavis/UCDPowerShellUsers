## Micrsoft Graph Device Management (Intune)

Part 3 of series on Microsoft Graph PowerShell SDK usage. This session will cover device management (Intune).

### Resource Links

[Microsoft Azure Portal](https://portal.azure.com/#allservices)

[Microsoft Intune Admin Center](https://intune.microsoft.com/#home)

[Microsoft.Graph.DeviceManagement Module](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.devicemanagement)

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

### Device Commands



