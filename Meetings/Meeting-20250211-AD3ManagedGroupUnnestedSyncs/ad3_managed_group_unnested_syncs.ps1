<#
    Title: ad3_managed_group_unnested_syncs.ps1
    Authors: Dean Bunn
    Inspired By: Ben Clark
    Last Edit: 2025-02-10
#>

#Import Custom uInform API Module 
Import-Module .\uInformAPI.psm1

#Custom Object for UC Davis API Information
$global:UCDAPIInfo = new-object PSObject -Property (@{ uinform_public_key=""; uinform_private_key=""; uinform_url_base="";});

#Load Public and Private Keys for uInform API Access
$UCDAPIInfo.uinform_public_key = Get-Secret -Name "uInformAPI-Pubkey" -AsPlainText -Vault UCDAccounts;
$UCDAPIInfo.uinform_private_key = Get-Secret -Name "uInformAPI-Pvtkey" -AsPlainText -Vault UCDAccounts;
$UCDAPIInfo.uinform_url_base = "https://ws.uinform.ucdavis.edu/";

#Array of Custom AD Unnested Group Settings
$arrADUnnestedGrpSyncs = @();

#Custom Object for AD3 Managed Unnested Group
$cstAD3UnnestMngdGrp1 = New-Object PSObject -Property (@{ AD3_Unnested_Grp_GUID="c462cf19-195a-4071-8273-02277b426a17";
                                                          AD3_Unnested_Grp_Name="COE-SW-Empire";
                                                          SRC_Nested_Groups_GUIDs=@("23e83beb-f5d6-476a-b1c7-505da5a9d0ad",
                                                                                    "5f5701c5-a2dc-4848-bada-621b9f30cfca",
                                                                                    "6fead534-0c18-4d98-8219-d9acc7d0e9aa"); 
                                                        });
#Add Custom AD3 Managed Unnested Groups to Sync Array
$arrADUnnestedGrpSyncs += $cstAD3UnnestMngdGrp1;

<#Example of How to Add Additional Unnested Groups to Sync Array.
$cstAD3UnnestMngdGrp2 = New-Object PSObject -Property (@{ AD3_Unnested_Grp_GUID="23e83beb-f5d6-476a-b1c7-505da5a9d0ad";
                                                          AD3_Unnested_Grp_Name="COE-SW-Republic";
                                                          SRC_Nested_Groups_GUIDs=@("b4961625-87fc-4aec-bc72-7201880b2e79");
                                                        });
$arrADUnnestedGrpSyncs += $cstAD3UnnestMngdGrp2; 
#>

#Initiate Principal Contexts for Both AD3 and OU Domains
$prctxAD3 = New-Object DirectoryServices.AccountManagement.PrincipalContext([DirectoryServices.AccountManagement.ContextType]::Domain,"AD3","DC=AD3,DC=UCDAVIS,DC=EDU");
$prctxOU = New-Object DirectoryServices.AccountManagement.PrincipalContext([DirectoryServices.AccountManagement.ContextType]::Domain,"OU","DC=OU,DC=AD3,DC=UCDAVIS,DC=EDU");

#Var for UCD Users DN Partial
[string]$ucdUsersDNPartial = ",ou=ucdusers,dc=ad3,dc=ucdavis,dc=edu";

#Var for UCD
[string]$managedGroupsDNPartial = ",ou=managedgroups,dc=ad3,dc=ucdavis,dc=edu";

#Loop Through Each AD Unnested Group Sync Custom Objects
foreach($cstAUGS in $arrADUnnestedGrpSyncs)
{
    #Hash Table for Source Groups Members GUIDs
    $htSrcGrpMbrGUIDs = @{};

    #Hash Table for Members to Remove from AD Group  
    $htMTRFG = @{};

    #HashTable for Members to Add to AD Group
    $htMTATG = @{};

    #Loop Through Each Nested Source Group
    foreach($srcGrpGUID in $cstAUGS.SRC_Nested_Groups_GUIDs)
    {
        #Var for Sync Source Group's LDAP Path Based Upon AD GUID
        [string]$grpLDAPPathSSG = "LDAP://ad3.ucdavis.edu/<GUID=" + $srcGrpGUID + ">";

        #Check for LDAP Path Before Pulling Group
        if([DirectoryServices.DirectoryEntry]::Exists($grpLDAPPathSSG) -eq $true)
        {
            #Initiate Directory Entry for Source Group
            $deADGroupSSG = New-Object DirectoryServices.DirectoryEntry($grpLDAPPathSSG);

            #Var for Group's DN
            [string]$grpDNSSG = $deADGroupSSG.Properties["distinguishedname"][0].ToString();

            #Var for GroupPrincipal for Sync Source Group
            $grpPrincipalSSG = $null;

            #Configure Group Principal Based Upon Domain of Source Group
            if($grpDNSSG.ToLower().Contains("dc=ou,") -eq $true)
            {
                $grpPrincipalSSG = [DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($prctxOU, [DirectoryServices.AccountManagement.IdentityType]::DistinguishedName,$grpDNSSG);
            }
            else 
            {
                $grpPrincipalSSG = [DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($prctxAD3, [DirectoryServices.AccountManagement.IdentityType]::DistinguishedName,$grpDNSSG);
            }

            #Check Membership Count of Sync Source Group
            if($grpPrincipalSSG.Members.Count -gt 0)
            {
                #Pull All Nested Membership for the Group
                foreach($ssgMbr in $grpPrincipalSSG.GetMembers($true))
                {
                    #Only Sync AD3 UCD Users 
                    if($ssgMbr.DistinguishedName.ToString().ToLower().EndsWith($ucdUsersDNPartial) -eq $true)
                    {

                        #Check for Unique Source Member's GUID
                        if($htSrcGrpMbrGUIDs.ContainsKey($ssgMbr.Guid.ToString()) -eq $false)
                        {
                            $htSrcGrpMbrGUIDs.Add($ssgMbr.Guid.ToString(),"1");
                        }

                    }
                    else 
                    {
                       Write-Output "User account is not meant for this sync tool"; 
                    }
                    
                }#End of Source Group Membership Foreach

            }#End of Membership Count Check on Sync Source Group

            #Close out Directory Entry for Source Group
            $deADGroupSSG.Close();

        }#End of Directory Entry Check on LDAP Path

    }#End of Source Nested Groups GUIDs Foreach

    #Pull Membership of Unnested Group
    #Var for LDAP Path of Unnested Group
    [string]$grpLDAPPathUNN = "LDAP://ad3.ucdavis.edu/<GUID=" + $cstAUGS.AD3_Unnested_Grp_GUID + ">"; 

    #Check LDAP Path of Unnested Group
    if([DirectoryServices.DirectoryEntry]::Exists($grpLDAPPathUNN) -eq $true)
    {
        #Initiate Directory Entry for Unnested Group
        $deADGroupUNN = New-Object DirectoryServices.DirectoryEntry($grpLDAPPathUNN);

        #Var for Group's DN
        [string]$grpDNUNN = $deADGroupUNN.Properties["distinguishedname"][0].ToString();

        #Check DN of Nested Group for Managed Groups Only
        if($grpDNUNN.ToLower().EndsWith($managedGroupsDNPartial) -eq $true)
        {
            #Var for GroupPrincipal for Unnested Group
            $grpPrincipalUNN = [DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($prctxAD3, [DirectoryServices.AccountManagement.IdentityType]::DistinguishedName,$grpDNUNN);
        
            #Check Membership Count of Unnested Group
            if($grpPrincipalUNN.Members.Count -gt 0)
            {
                #Pull All Unnested Membership for the Unnested Group
                foreach($unnMbr in $grpPrincipalUNN.GetMembers($false))
                {
                    #Load Current Members Into Remove Hash Table 
                    $htMTRFG.Add($unnMbr.Guid.ToString(),"1");
                    
                }#End of Source Group Membership Foreach

            }#End of Membership Count Check on Unnested Group
        
            #Determine Which Users to Remove or Add Using Source Group(s) Members
            if($htSrcGrpMbrGUIDs.Count -gt 0)
            {
                #Loop Through Source Groups Members Hash Table and Check Member Status
                foreach($dsGUID in $htSrcGrpMbrGUIDs.Keys)
                {
                    #Don't Remove Existing Members In Data Source Listing
                    if($htMTRFG.ContainsKey($dsGUID) -eq $true)
                    {
                        $htMTRFG.Remove($dsGUID);
                    }
                    else 
                    {
                        #Add Them to List to Be Added to Group
                        $htMTATG.Add($dsGUID.ToString(),"1");
                    }

                }#End of Data Source Members Add or Remove Checks

            }#End of $htSrcGrpMbrGUIDs Empty Check

            #Null\Empty Checks on uInform API Values
            if([string]::IsNullOrEmpty($UCDAPIInfo.uinform_public_key) -eq $false -and [string]::IsNullOrEmpty($UCDAPIInfo.uinform_public_key) -eq $false)
            {
                #Check for Members to Remove
                if($htMTRFG.Count -gt 0)
                {
                    foreach($mtrfg in $htMTRFG.Keys)
                    {
                        #Submit Remove Member Request to uInform API
                        Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID $cstAUGS.AD3_Unnested_Grp_GUID -MembershipAction "REMOVE" -MemberGUID $mtrfg.ToString();
                    
                    }#End of $htMTRFG.Keys Foreach

                }#End of Members to Remove

                #Check for Members to Add
                if($htMTATG.Count -gt 0)
                {
                    #Loop Through AD3 User GUIDs to Add to Group
                    foreach($mtatg in $htMTATG.Keys)
                    {
                        #Submit Add Member Request to uInform API
                        Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID $cstAUGS.AD3_Unnested_Grp_GUID -MembershipAction "ADD" -MemberGUID $mtatg.ToString();
                    
                    }#End of $htMTATG.Keys Foreach

                }#End of Members to Add

            }#End of Null\Empty Checks on uInform API Values

        }#Group DN Check for AD3 Groups Only

        #Close Out Directory Entry for Unnested Group
        $deADGroupUNN.Close();
        
    }#End of Unnested Group LDAP Path Exists Check

}#End of $arrADUnnestedGrpSyncs Foreach



