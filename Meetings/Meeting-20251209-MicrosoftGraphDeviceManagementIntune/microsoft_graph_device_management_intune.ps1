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

#View Managed Device by Device Name
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'COE-583QRF4'" | Format-List

#View Managed Devices with Name that Starts with Specific Characters
Get-MgDeviceManagementManagedDevice -Filter "startswith(deviceName,'coe-')" | Format-Table -AutoSize

#View Managed Devices Contains Specific Term in Device Name
Get-MgDeviceManagementManagedDevice -Filter "contains(deviceName,'LAB')" -All | `
Select-Object -Property Id,DeviceName,SerialNumber,UserDisplayName,OperatingSystem,AzureAdRegistered,LastSyncDateTime | Format-Table -AutoSize

#View All Detected Apps
Get-MgDeviceManagementDetectedApp -All 

#View Detected App by Name and Ordered by Device Count
Get-MgDeviceManagementDetectedApp -Filter "startswith(displayName,'Adobe')" -All | Sort-Object DeviceCount -Descending | Format-Table -AutoSize

#View Systems with Detected App by App ID
Get-MgDeviceManagementDetectedAppManagedDevice -DetectedAppId "0000e748dbcd48f12a0748524b02166e289200000000" `
   | Select-Object Id,DeviceName,OperatingSystem,OSVersion,DeviceRegistrationState,EmailAddress | Format-Table -AutoSize

#View Device Configuration Polices
Get-MgDeviceManagementDeviceConfiguration | `
Foreach-Object { Write-output "$([Environment]::NewLine)=================="; `
                 $_.DisplayName; `
                 Write-Output "==================$([Environment]::NewLine)"; `
                 $_.AdditionalProperties; `
                 Write-output "$([Environment]::NewLine)";}


#View Device Compliance Policy State Summary
Get-MgDeviceManagementDeviceCompliancePolicyDeviceStateSummary

#View Device Windows Protection State
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'COE-583QRF4'" | `
 Foreach-Object {  Get-MgDeviceManagementManagedDeviceWindowsProtectionState -ManagedDeviceId $_.Id }  | Format-List

#View Device Configuration State
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'LS-250184-LDO'" | `
 Foreach-Object {  Get-MgDeviceManagementManagedDeviceConfigurationState -ManagedDeviceId $_.Id }  | Format-Table -AutoSize

#View Managed Device User
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq 'COE-583QRF4'" | `
 Foreach-Object {  Get-MgDeviceManagementManagedDeviceUser -ManagedDeviceId $_.Id }  | Format-Table -AutoSize




#View Device's Group Membership
Get-MgDeviceMemberOf -DeviceId (Get-MgDevice -Filter "displayName eq 'COE-J238H03'").Id | Foreach-Object { Get-MgGroup -GroupId $_.Id }