<#
    Title: microsoft_graph_directory_management.ps1
    Authors: Dean Bunn and Justin Earley
    Last Edit: 2026-01-13
#>

#Stopping an Accidental Run
Exit;

#Install Required Modules
Install-Module -Name Microsoft.Graph.Authentication,
                     Microsoft.Graph.Users,
                     Microsoft.Graph.Groups,
                     Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser -Repository PSGallery -Force

#View Installed Modules
Get-InstalledModule

#View Available Commands in a Module
Get-Command -Module Microsoft.Graph.Identity.DirectoryManagement

#Import Required Modules
Import-Module Microsoft.Graph.Authentication,Microsoft.Graph.Users,Microsoft.Graph.Groups,Microsoft.Graph.Identity.DirectoryManagement

#Connect to Microsoft Graph
Connect-MgGraph

#Disconnect Microsoft Graph Session
Disconnect-MgGraph

#View All Federated and Managed Domains
Get-MgDomain -All | Sort-Object Id

#View Information about Specific Domain
Get-MgDomain -DomainId ece.ucdavis.edu | Format-List

#View Root Domain on Specific Domain
Get-MgDomainRootDomain -DomainId dbs.ucdavis.edu | Format-List

#Retrieve Organization Information Including Last Sync Information
Get-MgOrganization | Select-Object Id,DisplayName,OnPremisesLastSyncDateTime,OnPremisesSyncEnabled | Format-Table -AutoSize

#Retrieve Additional Information on Verified Domains
(Get-MgOrganization).VerifiedDomains | Select-Object Name,Type,IsInitial,IsDefault,Capabilities| Sort-Object Name | Format-Table -AutoSize 

#Get Federated Domains Configuration Information
(Get-MgOrganization).VerifiedDomains | Foreach-Object { if($_.Type -eq "Federated"){ Get-MgDomainFederationConfiguration -DomainId $_.Name | Format-List } }

#View Office365 Contacts
# Get-MgContact -All #Will take a very long time to complete. Not recommended

#Search for Contact by Mail Property
Get-MgContact -Search '"Mail:powershell@ucdavis.edu"' -ConsistencyLevel eventual -All | Format-List

#Search for Contact by a Specific Proxy Address
Get-MgContact -Filter "proxyAddresses/any(p:p eq 'smtp:powershell-request@lists.ucdavis.edu')" -ConsistencyLevel eventual -All | Format-List

#Find All Contacts with Addresses Starting with a Specific Term
Get-MgContact -Filter "proxyAddresses/any(p:startswith(p,'smtp:powershell'))" -ConsistencyLevel eventual -All
#Or
Get-MgContact -Filter "proxyAddresses/any(p:startswith(p,'SMTP:engr'))" -ConsistencyLevel eventual -All

#Find All Contacts from a Specific Domain
Get-MgContact -Filter "proxyAddresses/any(p:endswith(p,'@hotmail.com'))" -ConsistencyLevel eventual -All


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













#View Device's Group Membership
Get-MgDeviceMemberOf -DeviceId (Get-MgDevice -Filter "displayName eq 'COE-J238H03'").Id | Foreach-Object { Get-MgGroup -GroupId $_.Id }