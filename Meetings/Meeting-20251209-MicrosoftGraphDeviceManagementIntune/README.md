## Micrsoft Graph Device Management (Intune)

Part 3 of series on Microsoft Graph PowerShell SDK usage. This session will cover device management (Intune).

### Difference between MgDevice and MgDeviceManagementManagedDevice

> The cmdlets Get-MgDevice and Get-MgDeviceManagementManagedDevice both retrieve device information from Microsoft Graph, but they access different data sources and provide different levels of detail.

> Get-MgDevice: This cmdlet retrieves device objects from Microsoft Entra ID (formerly Azure Active Directory). It focuses on the directory object representation of a device within Entra ID, including properties like DisplayName, DeviceId, TrustType, and OperatingSystem. This cmdlet is useful for managing device identities within your Entra ID tenant and for tasks related to device registration and authentication.

> Get-MgDeviceManagementManagedDevice: This cmdlet retrieves managed device objects from Microsoft Intune. It provides more comprehensive information about devices enrolled and managed by Intune, including details specific to device management, such as SerialNumber, ComplianceState, LastSyncDateTime, ManagementAgent, and various device-specific properties related to operating system and hardware. This cmdlet is essential for tasks related to device compliance, configuration, and inventory within an Intune environment.

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
Get-MgDeviceManagementManagedDevice -ManagedDeviceId "0f121f24-032f-4d8b-bb40-3536b0be0fa1" | Format-List
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