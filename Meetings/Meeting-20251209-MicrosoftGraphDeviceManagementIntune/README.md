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

### Device Management Commands
View All Commands Related to Managed Devices in Device Management Module
```powershell
Get-Help -Name MgDeviceManagementManagedDevice | Select-Object -Property Name,Synopsis | Format-Table -AutoSize
```
View Managed Devices (View Only First 10)
```powershell
Get-MgDeviceManagementManagedDevice -Top 10
```
View All Managed Devices
```powershell
Get-MgDeviceManagementManagedDevice -All
```
View Managed Device by ID
```powershell
Get-MgDeviceManagementManagedDevice -ManagedDeviceId "76342a17-8e24-4cfc-a7ee-ddd939d92076" | Format-List
```
View Managed Device by Device Name
```powershell
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'COE-583QRF4'" | Format-List
```
View Managed Devices with Name that Starts with Specific Characters
```powershell
Get-MgDeviceManagementManagedDevice -Filter "startswith(deviceName,'coe-')" | Format-Table -AutoSize
```
View Managed Devices Contains Specific Term in Device Name
```powershell
Get-MgDeviceManagementManagedDevice -Filter "contains(deviceName,'LAB')" -All `
 | Select-Object -Property Id,DeviceName,SerialNumber,UserDisplayName,OperatingSystem,AzureAdRegistered,LastSyncDateTime | Format-Table -AutoSize
```
View All Detected Apps
```powershell
Get-MgDeviceManagementDetectedApp -All
```
View Detected App by Name and Ordered by Device Count
```powershell
Get-MgDeviceManagementDetectedApp -Filter "startswith(displayName,'Adobe')" -All | Sort-Object DeviceCount -Descending | Format-Table -AutoSize
```
View Systems with Detected App by App ID
```powershell
Get-MgDeviceManagementDetectedAppManagedDevice -DetectedAppId "0000e748dbcd48f12a0748524b02166e289200000000" `
   | Select-Object Id,DeviceName,OperatingSystem,OSVersion,DeviceRegistrationState,EmailAddress | Format-Table -AutoSize
```
View Device Configuration Polices
```powershell
Get-MgDeviceManagementDeviceConfiguration | `
  Foreach-Object { Write-output "$([Environment]::NewLine)=================="; `
                 $_.DisplayName; `
                 Write-Output "==================$([Environment]::NewLine)"; `
                 $_.AdditionalProperties; `
                 Write-output "$([Environment]::NewLine)";}
```
View Device Compliance Policy State Summary
```powershell
Get-MgDeviceManagementDeviceCompliancePolicyDeviceStateSummary
```
View Device Windows Protection State
```powershell
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'COE-583QRF4'" `
 | Foreach-Object {  Get-MgDeviceManagementManagedDeviceWindowsProtectionState -ManagedDeviceId $_.Id }  | Format-List
```
View Device Configuration State
```powershell
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'LS-250184-LDO'" `
 | Foreach-Object {  Get-MgDeviceManagementManagedDeviceConfigurationState -ManagedDeviceId $_.Id }  | Format-Table -AutoSize
```
View Managed Device User
```powershell
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'COE-583QRF4'" `
 | Foreach-Object {  Get-MgDeviceManagementManagedDeviceUser -ManagedDeviceId $_.Id }  | Format-Table -AutoSize
```
View Non Compliant Managed Devices and their Users
```powershell
Get-MgDeviceManagementManagedDevice -Filter "startswith(deviceName,'coe-') and ComplianceState eq 'noncompliant'" `
 | Select-Object ComplianceState,DeviceName,DeviceEnrollmentType,EmailAddress
```