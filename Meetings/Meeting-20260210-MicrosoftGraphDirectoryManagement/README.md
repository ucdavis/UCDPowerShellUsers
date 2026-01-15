## Micrsoft Graph Directory Management

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
Get-Command -Module Microsoft.Graph.Identity.DirectoryManagement
```
### Module Import and Connection Commands
Import Required Modules
```powershell
Import-Module Microsoft.Graph.Authentication,Microsoft.Graph.Users,Microsoft.Graph.Groups,Microsoft.Graph.Identity.DirectoryManagement
```
Connect to Microsoft Graph
```powershell
Connect-MgGraph
```
Disconnect Microsoft Graph Session
```powershell
Disconnect-MgGraph
```
### Domain Commands
View All Federated and Managed Domains
```powershell
Get-MgDomain -All | Sort-Object Id
```
View Information about Specific Domain
```powershell
Get-MgDomain -DomainId ece.ucdavis.edu | Format-List
```
View Root Domain on Specific Domain
```powershell
Get-MgDomainRootDomain -DomainId dbs.ucdavis.edu | Format-List
```
Retrieve Organization Information Including Last Sync Information
```powershell
Get-MgOrganization | Select-Object Id,DisplayName,OnPremisesLastSyncDateTime,OnPremisesSyncEnabled | Format-Table -AutoSize
```
Retrieve Additional Information on Verified Domains
```powershell
(Get-MgOrganization).VerifiedDomains | Select-Object Name,Type,IsInitial,IsDefault,Capabilities| Sort-Object Name | Format-Table -AutoSize 
```
Get Federated Domains Configuration Information
```powershell
(Get-MgOrganization).VerifiedDomains | Foreach-Object { if($_.Type -eq "Federated"){ Get-MgDomainFederationConfiguration -DomainId $_.Name | Format-List } }
```
### Contact Commands
View Office365 Contacts
```powershell
# Get-MgContact -All #Will take a very long time to complete. Not recommended
```
Search for Contact by Mail Property
```powershell
Get-MgContact -Search '"Mail:powershell@ucdavis.edu"' -ConsistencyLevel eventual -All | Format-List
```
Search for Contact by a Specific Proxy Address
```powershell
Get-MgContact -Filter "proxyAddresses/any(p:p eq 'smtp:powershell-request@lists.ucdavis.edu')" -ConsistencyLevel eventual -All | Format-List
```
Find All Contacts with Addresses Starting with a Specific Term
```powershell
Get-MgContact -Filter "proxyAddresses/any(p:startswith(p,'smtp:powershell'))" -ConsistencyLevel eventual -All
#Or
Get-MgContact -Filter "proxyAddresses/any(p:startswith(p,'SMTP:engr'))" -ConsistencyLevel eventual -All
```
Find All Contacts from a Specific Domain
```powershell
Get-MgContact -Filter "proxyAddresses/any(p:endswith(p,'@hotmail.com'))" -ConsistencyLevel eventual -All
```
```powershell
# Any Expression Format
# any(x: x eq 'value')
#     ^  ^
#     |  |
#     |  └─ reference to the current element
#     └──── variable declaration
#
# Filter Format Using Any Expression 
# collection/any(x:x eq 'value')
# collection/any(x:startswith(x,'value'))
# collection/any(x:endswith(x,'value'))
#
# Works Only on Properties that are Collections
```

### Device Commands
Retrieve All Devices
```powershell
Get-MgDevice -ConsistencyLevel eventual -All
```
Get Devices with a Specific Naming Structure
```powershell
Get-MgDevice -Filter "startswith(displayName,'coe-mae-')" -ConsistencyLevel eventual -All | `
 Select-Object Id,DisplayName,OperatingSystem,OperatingSystemVersion,TrustType,IsManaged,IsCompliant,RegistrationDateTime,ApproximateLastSignInDateTime | `
 Format-Table -AutoSize
```
Get Devices with a Specific Naming Prefix and have Signed In within the Last Two Months
```powershell
Get-MgDevice -Filter "startswith(displayName,'coe-mae-')" -ConsistencyLevel eventual -All | `
 Where-Object { $_.ApproximateLastSignInDateTime -ge (Get-Date).AddMonths(-2) } | `
 Select-Object Id,DisplayName,ApproximateLastSignInDateTime | Format-Table -AutoSize
```
```powershell
#The Returned "Id" is the "DeviceID" when Querying for Systems. 
```
Get Individual Device Information by "DeviceId" which is Really "Id"
```powershell
Get-MgDevice -DeviceId "3229f204-e0a3-47e5-8231-8d22d762f718" | Format-List
```
Get Individual Device Information by Actual DeviceId
```powershell
Get-MgDeviceByDeviceId -DeviceId "22d1b65f-a7e7-4ef1-993a-c84b10b0bd18" | Format-List
```
Get Individual Device Membership
```powershell
Get-MgDeviceMemberOf -DeviceId "db555ea7-69dc-4cda-8563-66505a2f4b8d" | Foreach-Object { $_.AdditionalProperties; write-output "`n`n"; }
#Or by Device Display Name
Get-MgDeviceMemberOf -DeviceId (Get-MgDevice -Filter "displayName eq 'COE-J238H03'").Id | Foreach-Object { $_.AdditionalProperties; write-output "`n`n"; }
```
Retrieve Registered Owner of Device
```powershell
Get-MgDeviceRegisteredOwner -DeviceId "db555ea7-69dc-4cda-8563-66505a2f4b8d" | Foreach-Object { $_.AdditionalProperties; }
#Or by Device Display Name 
Get-MgDeviceRegisteredOwner -DeviceId (Get-MgDevice -Filter "displayName eq 'COE-J238H03'").Id | Foreach-Object { $_.AdditionalProperties; }
```
Retrieve Registered User of Device
```powershell
Get-MgDeviceRegisteredUser -DeviceId "db555ea7-69dc-4cda-8563-66505a2f4b8d" | Foreach-Object { $_.AdditionalProperties; }
#Or
Get-MgDeviceRegisteredUser -DeviceId (Get-MgDevice -Filter "displayName eq 'COE-J238H03'").Id | Foreach-Object { $_.AdditionalProperties; }
```
Get Individual Device Membership Expanded Rules and Group Info
```powershell
Get-MgDeviceMemberOf -DeviceId "db555ea7-69dc-4cda-8563-66505a2f4b8d" | `
    Foreach-Object { foreach($ap in $_.AdditionalProperties) {
                       if($ap['@odata.type'].ToString().Contains("microsoft.graph.group"))
                       {    
                            #Var for Group Filter 
                            [string]$grpFilter = "displayName eq '" + $ap['displayName'] + "'";

                            #Pull Group by Display Name 
                            Get-MgGroup -Filter $grpFilter | Select-Object Id,DisplayName,MembershipRule
                       }
} } | Format-Table -AutoSize -Wrap
```