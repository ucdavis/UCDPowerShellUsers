<#
    Title: ad3_managed_groups_rights_check.ps1
    Authors: Dean Bunn
    Inspired By: Reuben Castelino
    Last Edit: 2025-06-10
#>

#Var for User ID of Admin Account to Compare Other Admins Access Against
[string]$usrIDComparisonAdm = "admin-dbunn";

#Var for GUID of Admin Group 
[string]$admGrpGuid = "7eef22bb-f34f-446e-95fe-30b36ae2344c";

#Pull Root AD Domain
$deADRoot = [DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().RootDomain.GetDirectoryEntry();

#Var for Domain Root
[string]$dmnRoot = $deADRoot.distinguishedName.ToString();

#Var for Managed Group OU
[string]$mngGrpOUPath = "LDAP://OU=Management,OU=ManagedGroups," + $dmnRoot;

#Var for LDAP Path Prefix for Group Lookup by GUID
[string]$dmnLDAPPathPrefixGuidLookup = $deADRoot.Path.ToString().Split('DC=')[0].ToString() + "<GUID=";

#HashTable for Comparison Admin's Managed Groups GUIDs
$htCAGuids = @{};

#HashTable for Other Admin's Managed Groups GUIDs
$htOAGuids = @{};

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

#Pull Search Result for Admin Account Comparison Account
[DirectoryServices.SearchResult]$srUICA = $dsSearcher.FindOne();

#Check for Required Properties to Lookup Comparison Admin Group Membership
if($srUICA.Properties["distinguishedName"].Count -gt 0)
{
    #Pull Directory Entry for Management Manage Groups OU
    [DirectoryServices.DirectoryEntry]$deMngmntMngGroupsOU = New-Object DirectoryServices.DirectoryEntry($mngGrpOUPath);
    
    #Set Search Root to Management Manage Groups OU
    $dsSearcher.SearchRoot = $deMngmntMngGroupsOU;

    #Check Comparison Admin Membership Count Before Pulling Nested Membership of Management Groups
    if($srUICA.Properties["memberof"].Count -gt 0)
    {
        #Set Search Filter to Look for All Groups User is a Member of
        $dsSearcher.Filter = "(&(objectclass=group)(member:1.2.840.113556.1.4.1941:=" + $srUICA.Properties["distinguishedName"][0].ToString() + "))";
        
        #Search for Management Group Membership
        [DirectoryServices.SearchResultCollection]$srchRlstColltMngtGrps = $dsSearcher.FindAll();

        #Empty Check on Comparison Admin Management Groups Search Results
        if($null -ne $srchRlstColltMngtGrps -and $srchRlstColltMngtGrps.Count -gt 0)
        {
            #Loop Through Search Results of Management Manage Groups
            foreach($srchRlstCMG in $srchRlstColltMngtGrps)
            {
                #Pull Associated Management Group Guid to Add to HashTable
                if($srchRlstCMG.Properties["extensionAttribute2"].Count -gt 0)
                {
                    #Var for Associated Management Group Guid
                    [string]$strGuidMngGrp = $srchRlstCMG.Properties["extensionAttribute2"][0].ToString().Trim();

                    #Add Associated Management Group Guid to Comparison Admin HashTable
                    if($htCAGuids.ContainsKey($strGuidMngGrp) -eq $false)
                    {
                        $htCAGuids.Add($strGuidMngGrp,"1");
                    }

                }#End of Associated Management Group Extension Attribute Check

            }#End of $srchRlstColltMngtGrps Foreach

        }#End of Comparison Admin Management Groups Search Results

    }#End of Comparison Admin Membership Count Check
    
    #Pull Other Admin Group Membership
    [string]$ldapPathAdminGrp = $dmnLDAPPathPrefixGuidLookup + $admGrpGuid + ">";
    
    #Directory Entry for Admin Group
    [DirectoryServices.DirectoryEntry]$deAdminGrp = New-Object DirectoryServices.DirectoryEntry($ldapPathAdminGrp);

    #Null Check on Admin Group Directory Entry
    if($null -ne $deAdminGrp -and $deAdminGrp.Properties["member"].Count -gt 0)
    {
       foreach($dnAdmGrpMbr in $deAdminGrp.Properties["member"])
       {
            Write-Output $dnAdmGrpMbr;
       }
    }
    
    #Close Out Directory Entry for Admin Group
    $deAdminGrp.Close();
    
    

    #Close Out Directory Entry for Management Manage Groups OU
    $deMngmntMngGroupsOU.Close();

}#End of Admin Account Comparison Account Lookup

#Close Out Directory Entry for Root Domain
$deADRoot.Close();

#C:\Users\dbunn\source\repos\UCDPowerShellUsers\Meetings\Meeting-20250610-AD3ManagedGroupsRightsCheck





















