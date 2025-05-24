<#
    Title: ad3_managed_groups_rights_check.ps1
    Authors: Dean Bunn
    Inspired By: Reuben Castelino
    Last Edit: 2025-06-10
#>

#Var for User ID of Admin Account to Compare Other Admins Access Against
[string]$usrIDComparisonAdm = "admin-dbunn";

#Pull Root AD Domain
$deADRoot = [DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().RootDomain.GetDirectoryEntry();

#Intitiate Directory Searcher
[DirectoryServices.DirectorySearcher]$dsSearcher = New-Object DirectoryServices.DirectorySearcher($deADRoot);
$dsSearcher.SearchScope = [DirectoryServices.SearchScope]::Subtree;
$dsSearcher.PageSize = 900;
[void]$dsSearcher.PropertiesToLoad.Add("distinguishedName");
[void]$dsSearcher.PropertiesToLoad.Add("memberof");
[void]$dsSearcher.PropertiesToLoad.Add("objectGuid");
[void]$dsSearcher.PropertiesToLoad.Add("extensionAttribute2");
[void]$dsSearcher.PropertiesToLoad.Add("extensionAttribute3");
[void]$dsSearcher.PropertiesToLoad.Add("extensionAttribute4");

#Search for Account for Comparison Admin
$dsSearcher.Filter = "(&(objectclass=user)(sAMAccountName=" + $usrIDComparisonAdm + "))";
[DirectoryServices.SearchResult]$srUICA = $dsSearcher.FindOne();

#Check for Required Properties to Lookup Comparison Admin Group Membership
if($srUICA.Properties["distinguishedName"].Count -gt 0 -and $srUICA.Properties["memberof"].Count -gt 0)
{
    Write-Output $srUICA.Properties["distinguishedName"][0].ToString();
    Write-Output $srUICA.Properties["memberof"][3].ToString();
}
 
#C:\Users\dbunn\source\repos\UCDPowerShellUsers\Meetings\Meeting-20250610-AD3ManagedGroupsRightsCheck

#GUID of ad3\COE-IT-AdminAcnts
##7eef22bb-f34f-446e-95fe-30b36ae2344c

#$deADRoot.distinguishedName; #DC=ad3,DC=ucdavis,DC=edu


#Forest.GetCurrentForest().RootDomain.GetDirectoryEntry();