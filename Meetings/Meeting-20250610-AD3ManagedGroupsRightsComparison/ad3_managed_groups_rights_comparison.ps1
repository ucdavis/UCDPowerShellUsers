<#
    Title: ad3_managed_groups_rights_comparison.ps1
    Authors: Dean Bunn
    Inspired By: Reuben Castelino and Ben Clark
    Last Edit: 2025-06-10
#>

#Var for User ID of Account to Compare Rights Access to Members of Benchmark Group or Individual Benchmark User
[string]$usrIDComparisonAcnt = "admin-dbunn";

#Var for User ID of Individual Benchmark User Account
[string]$benchmarkUsrID = "admin-benclark";

#Var for Group GUID of Benchmark Members of AD3 Group
[string]$benchmarkAD3GrpGuid = "7eef22bb-f34f-446e-95fe-30b36ae2344c";

#Pull Root AD Domain
$deADRoot = [DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().RootDomain.GetDirectoryEntry();

#Var for Domain Root
[string]$dmnRoot = $deADRoot.distinguishedName.ToString();

#Var for Managed Group OU
[string]$mngGrpOUPath = "LDAP://OU=Management,OU=ManagedGroups," + $dmnRoot;

#Var for LDAP Path Prefix for Group Lookup by GUID
[string]$dmnLDAPPathPrefixGuidLookup = $deADRoot.Path.ToString().Split('DC=')[0].ToString() + "<GUID=";

#HashTable for Comparison Account's Managed Groups GUIDs
$htCAGuids = @{};

#HashTable for Benchmark User's Managed Groups GUIDs
$htBUGuids = @{};

#Array for Custom Reporting Objects
$arrRptMngGrpsMissingRights = @();

#Var for Report Name
[string]$rptName = "Managed_Groups_Missing_Access_Rights_Report_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv";

#Pull Directory Entry for Management Manage Groups OU
[DirectoryServices.DirectoryEntry]$deMngmntMngGroupsOU = New-Object DirectoryServices.DirectoryEntry($mngGrpOUPath);

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
$dsSearcher.Filter = "(&(objectclass=user)(sAMAccountName=" + $usrIDComparisonAcnt + "))";

#Pull Search Result for Comparison Account
[DirectoryServices.SearchResult]$srUICA = $dsSearcher.FindOne();

#Check for Required Properties to Lookup Comparison Account Group Membership
if($srUICA.Properties["distinguishedName"].Count -gt 0)
{
    #Set Search Root to Management Manage Groups OU
    $dsSearcher.SearchRoot = $deMngmntMngGroupsOU;

    #Check Comparison User Membership Count Before Pulling Nested Membership of Management Groups
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

                    #Add Associated Management Group Guid to Comparison Account HashTable
                    if($htCAGuids.ContainsKey($strGuidMngGrp) -eq $false)
                    {
                        $htCAGuids.Add($strGuidMngGrp,"1");
                    }

                }#End of Associated Management Group Extension Attribute Check

            }#End of $srchRlstColltMngtGrps Foreach

        }#End of Comparison Account Management Groups Search Results

    }#End of Comparison Account Membership Count Check
    
}#End of Comparison Account Lookup

#Null\Empty Check on Benchmark User Account
if([string]::IsNullOrEmpty($benchmarkUsrID) -eq $false)
{
    #Set Search Root to Back to Root Domain
    $dsSearcher.SearchRoot = $deADRoot;

    #Search for Account for Benmark Individual User Account
    $dsSearcher.Filter = "(&(objectclass=user)(sAMAccountName=" + $benchmarkUsrID + "))";

    #Pull Search Result for Benchmark Individual User
    [DirectoryServices.SearchResult]$srBIU = $dsSearcher.FindOne();

    #Check for Required Properties to Lookup Individual Benchmark User's Group Membership
    if($srBIU.Properties["distinguishedName"].Count -gt 0)
    {
        #Set Search Root to Management Manage Groups OU
        $dsSearcher.SearchRoot = $deMngmntMngGroupsOU;

        #Check Benchmark Individual User's Membership Count Before Pulling Nested Membership of Management Groups
        if($srBIU.Properties["memberof"].Count -gt 0)
        {

            #Set Search Filter to Look for All Groups Individual Benchmark User is a Member of
            $dsSearcher.Filter = "(&(objectclass=group)(member:1.2.840.113556.1.4.1941:=" + $srBIU.Properties["distinguishedName"][0].ToString() + "))";
        
            #Search for Management Group Membership
            [DirectoryServices.SearchResultCollection]$srchRlstBIUColltMngtGrps = $dsSearcher.FindAll();

            #Empty Check on Benchmark Individual User Management Groups Search Results
            if($null -ne $srchRlstBIUColltMngtGrps -and $srchRlstBIUColltMngtGrps.Count -gt 0)
            {
                #Loop Through Search Results of Benchmark Individual User's Management Manage Groups
                foreach($srchRlstBIUMG in $srchRlstBIUColltMngtGrps)
                {
                    #Pull Associated Management Group Guid to Add to Benchmark User's HashTable
                    if($srchRlstBIUMG.Properties["extensionAttribute2"].Count -gt 0)
                    {
                        #Var for Associated Management Group Guid
                        [string]$strGuidMngGrp = $srchRlstBIUMG.Properties["extensionAttribute2"][0].ToString().Trim();

                        #Add Associated Management Group Guid to Benchmark User's HashTable
                        if($htBUGuids.ContainsKey($strGuidMngGrp) -eq $false)
                        {
                            $htBUGuids.Add($strGuidMngGrp,"1");
                        }

                    }#End of Associated Management Group Extension Attribute Check

                }#End of $srchRlstBIUColltMngtGrps Foreach

            }#End of Benchmark Individual User's Management Groups Search Results

        }#End of $srBIU memberof count check

    }#End of DN Check on $srBIU

}#End of Null\Empty Check on Benchmark Individual User Account

#Null\Empty Check on Benchmark Group Guid
if([string]::IsNullOrEmpty($benchmarkAD3GrpGuid) -eq $false)
{
    #Set LDAP Path for Benchmark Group Membership
    [string]$ldapPathBenchmarkGrp = $dmnLDAPPathPrefixGuidLookup + $benchmarkAD3GrpGuid + ">";
    
    #Directory Entry for Benchmark Users
    [DirectoryServices.DirectoryEntry]$deBenchMarkGrp = New-Object DirectoryServices.DirectoryEntry($ldapPathBenchmarkGrp);

    #Null Check on Benchmark Group Directory Entry
    if($null -ne $deBenchMarkGrp -and $deBenchMarkGrp.Properties["member"].Count -gt 0)
    {
        #Loop Through Each Benchmark Group Member and Pull Their Management Group Membership
        foreach($dnBUGrpMbr in $deBenchMarkGrp.Properties["member"])
        {
            #Set Search Filter to Look for All Groups Benchmark User is a Member of in the Management OU
            $dsSearcher.Filter = "(&(objectclass=group)(member:1.2.840.113556.1.4.1941:=" + $dnBUGrpMbr.ToString() + "))";
            
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

                        #Add Associated Management Group Guid to Benchmark User HashTable
                        if($htBUGuids.ContainsKey($strGuidMngGrp) -eq $false)
                        {
                            $htBUGuids.Add($strGuidMngGrp,"1");
                        }

                    }#End of Associated Management Group Extension Attribute Check

                }#End of $srchRlstColltOtherAdminsMngtGrps Foreach

            }#End of Null\Empty Check on $srchRlstColltOtherAdminsMngtGrps

        }#End of Foreach On Benchmark User Group Membership

    }#End of Null\Empty Check on Benchmark Users Group

    #Close Out Directory Entry for Benchmark Group
    $deBenchMarkGrp.Close();

}#End of $benchmarkAD3GrpGuid Null\Empty Check

#Close Out Directory Entry for Management Manage Groups OU
$deMngmntMngGroupsOU.Close();

#Determine Which Groups Comparison Account is Not an Owner or Manager On. 
if($htCAGuids.Count -gt 0)
{
    #Loop Through Comparison Account's Groups and Remove Guids In Benchmark Users Guids HashTable
    foreach($caGUID in $htCAGuids.Keys)
    {
        if($htBUGuids.ContainsKey($caGUID) -eq $true)
        {
            $htBUGuids.Remove($caGUID);
        }

    }#End of $htCAGuids.Keys Foreach

}#End of Comparison HashTable Checks

#Check for Benchmark Groups to Report On
if($htBUGuids.Count -gt 0)
{
    #Loop Through Remaining Benchmark Users Managed Group Guids and Report Them Out
    foreach($buGUID in $htBUGuids.Keys)
    {
        
        #Var for LDAP Path to Managed Group that Benchmark User(s) Have Rights To
        [string]$ldapPathBUManagedGrp = $dmnLDAPPathPrefixGuidLookup + $buGUID + ">";
    
        #Directory Entry for Benchmark User(s) Group
        [DirectoryServices.DirectoryEntry]$deBUMngdGrp = New-Object DirectoryServices.DirectoryEntry($ldapPathBUManagedGrp);

        #Null Check on No Access Rights Group
        if($null -ne $deBUMngdGrp -and $deBUMngdGrp.Properties["cn"].Count -gt 0)
        {
            #Create Custom Reporting Object for Managed Group Comparison User doesn't have access to
            $cstMngGrp = [PSCustomObject]@{
                                            Guid       = $deBUMngdGrp.Guid.ToString()
                                            GroupName  = $deBUMngdGrp.Properties["cn"][0]
                                            GroupLink  = "https://admin.uinform.ucdavis.edu/GroupManagement/Details/" + $deBUMngdGrp.Guid.ToString()
                                          };
            
            # Add Custom Object to Reporting Array
            $arrRptMngGrpsMissingRights += $cstMngGrp;

        }#End of Null Check on No Access Rights Group

        #Close Out Benchmark Managed Group
        $deBUMngdGrp.Close();
        
    }#End of $htOAGuids.Keys Foreach

}#End of $htBMGuids Count Check

#Close Out Directory Entry for Root Domain
$deADRoot.Close();

#Export Report to Local Directory
$arrRptMngGrpsMissingRights | Sort-Object -Property GroupName | Select-Object -Property Guid,GroupName,GroupLink | Export-Csv -Path $rptName -NoTypeInformation;

#Display Report 
$arrRptMngGrpsMissingRights | Sort-Object -Property GroupName | Select-Object -Property Guid,GroupName






















