<#
    Title: ad3_managed_groups_rights_check.ps1
    Authors: Dean Bunn
    Inspired By: Reuben Castelino and Ben Clark
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

#Array for Custom Reporting Objects
$arrRptMngGrpsMissingRights = @();

#Var for Report Name
[string]$rptName = "Managed_Groups_Missing_Access_Rights_Report_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv";

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
        #Loop Through Each Admin Group Member and Pull There Management Groups
        foreach($dnAdmGrpMbr in $deAdminGrp.Properties["member"])
        {
            #Set Search Filter to Look for All Groups Admin User is a Member of in the Management OU
            $dsSearcher.Filter = "(&(objectclass=group)(member:1.2.840.113556.1.4.1941:=" + $dnAdmGrpMbr.ToString() + "))";
        
            #Search for Management Group Membership
            [DirectoryServices.SearchResultCollection]$srchRlstColltOtherAdminsMngtGrps = $dsSearcher.FindAll();

            #Null\Empty Check on Admin Account Group Membership
            if($null -ne $srchRlstColltOtherAdminsMngtGrps -and $srchRlstColltOtherAdminsMngtGrps.Count -gt 0)
            {
                #Loop Through Search Results of Other Admins Management Manage Groups
                foreach($srchRlstOMG in $srchRlstColltOtherAdminsMngtGrps)
                {
                    #Pull Associated Management Group Guid to Add to HashTable
                    if($srchRlstOMG.Properties["extensionAttribute2"].Count -gt 0)
                    {
                        #Var for Associated Management Group Guid
                        [string]$strGuidMngGrp = $srchRlstOMG.Properties["extensionAttribute2"][0].ToString().Trim();

                        #Add Associated Management Group Guid to Comparison Admin HashTable
                        if($htOAGuids.ContainsKey($strGuidMngGrp) -eq $false)
                        {
                            $htOAGuids.Add($strGuidMngGrp,"1");
                        }

                    }#End of Associated Management Group Extension Attribute Check

                }#End of $srchRlstColltOtherAdminsMngtGrps Foreach

            }#End of Null\Empty Check on $srchRlstColltOtherAdminsMngtGrps

       }#End of Foreach On Admin Accounts Group Membership

    }#End of Null\Empty Check on Admin Group
    
    #Close Out Directory Entry for Admin Group
    $deAdminGrp.Close();
    
    #Close Out Directory Entry for Management Manage Groups OU
    $deMngmntMngGroupsOU.Close();

}#End of Admin Account Comparison Account Lookup

#Determine Which Groups Comparison Admin is Not an Owner or Manager On. 
if($htCAGuids.Count -gt 0)
{
    #Loop Through Comparison Admin Groups and Remove Guids In Other Guids HashTable
    foreach($caGUID in $htCAGuids.Keys)
    {
        if($htOAGuids.ContainsKey($caGUID) -eq $true)
        {
            $htOAGuids.Remove($caGUID);
        }

    }#End of $htCAGuids.Keys Foreach

}#End of Comparison HashTable Checks

#Check for Groups to Report On
if($htOAGuids.Count -gt 0)
{

    #Loop Through Remaining Other Admin Managed Group Guids and Report Them Out
    foreach($oaGUID in $htOAGuids.Keys)
    {
        
        #Var for LDAP Path to Managed Group that Other Admins Have Rights To
        [string]$ldapPathOAManagedGrp = $dmnLDAPPathPrefixGuidLookup + $oaGUID + ">";
    
        #Directory Entry for Admin Group
        [DirectoryServices.DirectoryEntry]$deOAMngdGrp = New-Object DirectoryServices.DirectoryEntry($ldapPathOAManagedGrp);

        #Null Check on No Access Rights Group
        if($null -ne $deOAMngdGrp -and $deOAMngdGrp.Properties["cn"].Count -gt 0)
        {
            #Create Custom Reporting Object for Managed Group Comparison Admin doesn't have access to
            $cstMngGrp = [PSCustomObject]@{
                                            Guid       = $deOAMngdGrp.Guid.ToString()
                                            GroupName  = $deOAMngdGrp.Properties["cn"][0]
                                            GroupLink  = "https://admin.uinform.ucdavis.edu/GroupManagement/Details/" + $deOAMngdGrp.Guid.ToString()
                                          };
            
            #Add Custom Object to Reporting Array
            $arrRptMngGrpsMissingRights += $cstMngGrp;

        }#End of Null Check on No Access Rights Group
        
    }#End of $htOAGuids.Keys Foreach

}#End of $htOAGuids Count Check

#Close Out Directory Entry for Root Domain
$deADRoot.Close();

#Export Report to Local Directory
$arrRptMngGrpsMissingRights | Sort-Object -Property GroupName | Select-Object -Property Guid,GroupName,GroupLink | Export-Csv -Path $rptName -NoTypeInformation;

#Display Report 
$arrRptMngGrpsMissingRights | Sort-Object -Property GroupName | Select-Object -Property Guid,GroupName


#C:\Users\dbunn\source\repos\UCDPowerShellUsers\Meetings\Meeting-20250610-AD3ManagedGroupsRightsCheck





















