<#
    Title: microsoft_graph_sdk_demo.ps1
    Authors: Justin Earley and Dean Bunn
    Last Edit: 2025-09-09
#>

#Stopping an Accidental Run
Exit;

#View Individual User in our Entra tenant 
Get-MgUser -UserId "dbunn@ucdavis.edu"

#View Individual User Full Information
Get-MgUser -UserId "benclark@ucdavis.edu" | Format-List 

#View Individual User's On Premise Extension Attributes 
Get-MgUser -UserId "dbunn@ucdavis.edu" -Property onPremisesExtensionAttributes | Select-Object -ExpandProperty onPremisesExtensionAttributes | Format-List

#Search for All Members with a Specific Last Name
Get-MgUser -Search '"Surname:Bunn"' -ConsistencyLevel eventual -All | Format-Table -AutoSize

#Search for a Specific Member by Mail 
Get-MgUser -Filter "mail eq 'jeremy@ucdavis.edu'" 

#Search for All Groups that Start with a Specific Term
Get-MgGroup -Filter "startsWith(displayName, 'LS-')" -ConsistencyLevel eventual -All

#View All Direct Members of a Specific Group
Get-MgGroupMember -GroupId (Get-MgGroup -Filter "displayName eq 'COE-US-IT'").Id -All | ForEach-Object { Get-MgUser -UserId $_.Id } | Format-Table -AutoSize

#View Individual User's Group Membership
Get-MgUserMemberOf -UserId (Get-MgUser -UserId 'dbunn@ucdavis.edu').Id -All | ForEach-Object { Get-MgGroup -GroupId $_.Id } | Select-Object Id,DisplayName,Description | Sort-Object DisplayName | Format-Table -AutoSize

#View Non Compliant Managed Devices and their Users
Get-MgDeviceManagementManagedDevice -Filter "startswith(deviceName,'coe-') and ComplianceState eq 'noncompliant'" | Select-Object ComplianceState,DeviceName,DeviceEnrollmentType,EmailAddress