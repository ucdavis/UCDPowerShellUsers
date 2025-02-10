<#
    Title: ad3_managed_group_empty_membership.ps1
    Authors: Dean Bunn
    Inspired By: Ben Clark
    Last Edit: 2025-02-10
#>

#Var for AD3 Managed Group GUID to Empty Membership
[string]$AD3_Grp_GUID = "c462cf19-195a-4071-8273-02277b426a17";

#Import Custom uInform API Module (From the Folder Up One Level)
Import-Module ..\uInformAPI.psm1

#Custom Object for UC Davis API Information
$global:UCDAPIInfo = new-object PSObject -Property (@{ uinform_public_key=""; uinform_private_key=""; uinform_url_base="";});

#Load Public and Private Keys for uInform API Access
$UCDAPIInfo.uinform_public_key = Get-Secret -Name "uInformAPI-Pubkey" -AsPlainText -Vault UCDAccounts;
$UCDAPIInfo.uinform_private_key = Get-Secret -Name "uInformAPI-Pvtkey" -AsPlainText -Vault UCDAccounts;
$UCDAPIInfo.uinform_url_base = "https://ws.uinform.ucdavis.edu/";

#Hash Table for Members to Remove from AD Group  
$htMTRFG = @{};

#Initiate Principal Contexts for Both AD3 Domain
$prctxAD3 = New-Object DirectoryServices.AccountManagement.PrincipalContext([DirectoryServices.AccountManagement.ContextType]::Domain,"AD3","DC=AD3,DC=UCDAVIS,DC=EDU");

#Var for LDAP Path of Unnested Group
[string]$grpLDAPPath = "LDAP://ad3.ucdavis.edu/<GUID=" + $AD3_Grp_GUID + ">"; 

#Check LDAP Path of Unnested Group
if([DirectoryServices.DirectoryEntry]::Exists($grpLDAPPath) -eq $true)
{
    #Initiate Directory Entry for Group
    $deADGroup = New-Object DirectoryServices.DirectoryEntry($grpLDAPPath);

    #Var for Group's DN
    [string]$grpDN = $deADGroup.Properties["distinguishedname"][0].ToString();

    #Var for GroupPrincipal for Group
    $grpPrincipal = [DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($prctxAD3, [DirectoryServices.AccountManagement.IdentityType]::DistinguishedName,$grpDN);
        
    #Check Membership Count of Unnested Group
    if($grpPrincipal.Members.Count -gt 0)
    {
        #Pull All Unnested Membership for the Unnested Group
        foreach($mbr in $grpPrincipal.GetMembers($false))
        {
            #Load Current Members Into Remove Hash Table 
            $htMTRFG.Add($mbr.Guid.ToString(),"1");
            
        }#End of Source Group Membership Foreach

    }#End of Membership Count Check on Unnested Group

    #Null\Empty Checks on uInform API Values
    if([string]::IsNullOrEmpty($UCDAPIInfo.uinform_public_key) -eq $false -and [string]::IsNullOrEmpty($UCDAPIInfo.uinform_public_key) -eq $false)
    {

        #Check for Members to Remove
        if($htMTRFG.Count -gt 0)
        {
            foreach($mtrfg in $htMTRFG.Keys)
            {
                #Submit Remove Member Request to uInform API
                Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID $AD3_Grp_GUID -MembershipAction "REMOVE" -MemberGUID $mtrfg.ToString();
            
            }#End of $htMTRFG.Keys Foreach

        }#End of Members to Remove

    }#End of Null\Empty Checks on uInform API Values

}#End of AD Group Path Exists Check
