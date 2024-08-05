<#
    Title: ad3_offboarding.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-07-06
#>

#Import Custom uInform API Module (One Function to Remove Membership in a Group)
Import-Module .\uInformAPI.psm1

#Var for AD3 Account of uInform API Keys
$admUsrID = "admin-dbunn";

#Var for Offboarding AD3 Member
$offBoardUsrID = "coehack";

#Custom Object for UC Davis API Information
$global:UCDAPIInfo = new-object PSObject -Property (@{ uinform_public_key=""; uinform_private_key=""; uinform_url_base=""; iam_key=""; iam_url_base="";});

#Load Public and Private Keys for uInform and IAM API Access
$UCDAPIInfo.uinform_public_key = Get-Secret -Name "uInformAPI-Pubkey" -AsPlainText -Vault UCDInfo;
$UCDAPIInfo.uinform_private_key = Get-Secret -Name "uInformAPI-Pvtkey" -AsPlainText -Vault UCDInfo;
$UCDAPIInfo.uinform_url_base = "https://ws.uinform.ucdavis.edu/";
$UCDAPIInfo.iam_key = Get-Secret -Name "IAM-Key" -AsPlainText -Vault UCDInfo;
$UCDAPIInfo.iam_url_base = "https://iet-ws.ucdavis.edu/api/iam/";

#Var for uInform Management OU
$uInformManagementOU = "OU=Management,OU=ManagedGroups,DC=ad3,DC=ucdavis,DC=edu";

#Var for AD3 Domain
$ad3Domain = "ad3.ucdavis.edu";

#HashTable of uInform Management Groups Admin is a Member Of
$htuMngGrpGuidsExt34 = @{};

#HashTable of uInform Managed Groups Admin has Rights On
$htuMngGrpGuidsExt2 = @{};

#Array of Addition Group Properties to Retrieve
[string[]]$arrGrpProps = "extensionAttribute2","extensionAttribute3","extensionAttribute4";

#Var for AD3 Admin Account
$ad3AdminAcnt = Get-ADUser -Identity $admUsrID -Server $ad3Domain -Properties "memberof";

#Null\Empty Check on AD3 Admin Account 
if([string]::IsNullOrEmpty($ad3AdminAcnt.DistinguishedName) -eq $false -and $ad3AdminAcnt.MemberOf.Count -gt 0)
{

    #Var for AD Group Search Filter
    $grpSrchFilter = "(&(objectclass=group)(member:1.2.840.113556.1.4.1941:=" + $ad3AdminAcnt.DistinguishedName.ToString() + "))";

    #Pull AD3 Management Groups the Admin is a Member Of
    $uManagedOUGrps = Get-ADGroup -LDAPFilter $grpSrchFilter -SearchBase $uInformManagementOU -Server $ad3Domain -Properties "extensionAttribute2";

    #Loop Through Management Groups and Add The Management Group and the Group it Controls to Respective HashTables
    foreach($uMngOUGrp in $uManagedOUGrps)
    {

        #Check and Add for the Management Group Guid
        if($htuMngGrpGuidsExt34.ContainsKey($uMngOUGrp.ObjectGUID.ToString()) -eq $false)
        {
            $htuMngGrpGuidsExt34.Add($uMngOUGrp.ObjectGUID.ToString(),"1");
        }

        #Check and Add Managed Related Group Guid
        if($htuMngGrpGuidsExt2.ContainsKey($uMngOUGrp.extensionAttribute2.ToString()) -eq $false)
        {
            $htuMngGrpGuidsExt2.Add($uMngOUGrp.extensionAttribute2.ToString(),"1");
        }

    }#End of $uManagedOUGrps Foreach

}#End of Null\Empty Check on AD3 Admin Account

#Pull Offboard Member Group Memberships
$offBoardMbr = Get-ADUser -Identity $offBoardUsrID -Server $ad3Domain -Properties "memberOf";

#Check for Offboard User Group Membership Count
if($offBoardMbr.MemberOf.Count -gt 0)
{
    #Loop Through Offboard User Membership
    foreach($obGrpDN in $offBoardMbr.MemberOf)
    {

        #AD3 Managed Service Groups Only Check
        if($obGrpDN.ToString().ToLower().Contains(",ou=managedgroups,dc=ad3,dc=ucdavis,dc=edu") -eq $true)
        {
            #Pull AD3 Group
            $obmGrp = Get-ADGroup -Identity $obGrpDN -Server $ad3Domain -Properties $arrGrpProps;

            #Check to See If Admin Account has Rights to Group. Else If Is Group a Management Group that Admin Account has Manager or Owner Rights On
            if($htuMngGrpGuidsExt2.ContainsKey($obmGrp.ObjectGUID.ToString()) -eq $true)
            {
                
                #Submit AD3 Managed Group Membership Change
                Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID $obmGrp.ObjectGUID.ToString() -MembershipAction "REMOVE" -MemberGUID $offBoardMbr.ObjectGUID.ToString();

            }
            elseif($obmGrp.DistinguishedName.ToString().Contains($uInformManagementOU) -eq $true -and $htuMngGrpGuidsExt2.ContainsKey($obmGrp.extensionAttribute2.ToString()) -eq $true)
            {

                #Pull Regular Related Managed Group to Determine If User has Owners or Managers rights
                $rgrMngGrp = Get-ADGroup -Identity $obmGrp.extensionAttribute2.ToString() -Server $ad3Domain -Properties $arrGrpProps;

                #Check Regular Managed Group for Managers Related Group Guid (extensionAttribute4). Removes Manager Rights
                if([string]::IsNullOrEmpty($rgrMngGrp.extensionAttribute4) -eq $false -and $rgrMngGrp.extensionAttribute4.ToString() -eq $obmGrp.ObjectGUID.ToString())
                {
                    #Submit AD3 Managed Group Membership Change
                    Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID $obmGrp.ObjectGUID.ToString() -MembershipAction "REMOVE" -MemberGUID $offBoardMbr.ObjectGUID.ToString();
                }

                #Check Regular Managed Group for Owners Related Group Guid (extensionAttribute3)
                #Only Remove Owners Rights for the Offboarding Member if the Admin Account Already has Ownership Rights
                if([string]::IsNullOrEmpty($rgrMngGrp.extensionAttribute3) -eq $false -and $rgrMngGrp.extensionAttribute3.ToString() -eq $obmGrp.ObjectGUID.ToString() -and $htuMngGrpGuidsExt34.ContainsKey($rgrMngGrp.extensionAttribute3.ToString()) -eq $true)
                {
                    #Submit AD3 Managed Group Membership Change
                    Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID $obmGrp.ObjectGUID.ToString() -MembershipAction "REMOVE" -MemberGUID $offBoardMbr.ObjectGUID.ToString();
                }

            }#End of Admin Account Rights Checks
            
        }#End of AD3 Groups Only Check
        
    }#End of MemberOf Foreach

}#End of Offboard User Group Membership Count

