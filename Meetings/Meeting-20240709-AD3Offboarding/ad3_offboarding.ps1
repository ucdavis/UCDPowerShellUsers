<#
    Title: ad3_offboarding.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-07-03
#>

#Var for AD3 Account of uInform API Keys
$admUsrID = "admin-dbunn";

#Var for Offboarding AD3 Member
$offBoardUsrID = "coehack";

#Custom Object for UC Davis API Information
$global:UCDAPIInfo = new-object PSObject -Property (@{ uinform_public_key=""; uinform_private_key=""; uinform_url_base=""; iam_key=""; iam_url_base=";"});

#Load Public and Private Keys for uInform and IAM API Access
$UCDAPIInfo.uinform_public_key = Get-Secret -Name "uInformAPI-Pubkey" -AsPlainText -Vault UCDInfo;
$UCDAPIInfo.uinform_private_key = Get-Secret -Name "uInformAPI-Pvtkey" -AsPlainText -Vault UCDInfo;
$UCDAPIInfo.uinform_url_base = "https://ws.uinform.ucdavis.edu/";
$UCDAPIInfo.iam_key = Get-Secret -Name "IAM-Key" -AsPlainText -Vault UCDInfo;
$UCDAPIInfo.iam_url_base = "https://iet-ws.ucdavis.edu/api/iam/";

#Function for Submitting an AD3 Managed Group Membership Change
function Submit-uInformAPIAD3ManagedGroupMembershipChange()
{
    Param
    (
         [Parameter(Mandatory=$true)]
         [string] $GroupGUID,
         [Parameter(Mandatory=$true)]
         [string] $MembershipAction,
         [Parameter(Mandatory=$true)]
         [string] $MemberGUID
    )

    #Custom Object for Post Body
    $cstPostBody = new-object PSObject -Property(@{ userGuid=""; action="";});
    $cstPostBody.userGuid = $MemberGUID
    $cstPostBody.action = $MembershipAction.ToString().ToUpper();

    #Convert Post Body to Json Object
    $jsonPostBody = $cstPostBody | ConvertTo-Json -Compress;

    #Var for Http Method
    $method = "POST"

    #Configure Request Signature
    $timestamp =[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
    $sig = $method + ":" + $timestamp + ":" + $UCDAPIInfo.uinform_public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($UCDAPIInfo.uinform_private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $UCDAPIInfo.uinform_url_base + "ManagedGroups/" + $GroupGUID + "/members"

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($UCDAPIInfo.uinform_public_key, $p)

    #Make API request, selecting JSON properties from response
    $rspObj = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing -Body $jsonPostBody -ContentType "application/json" | ConvertFrom-Json;

    return $rspObj.responseObject;
}

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

    #Loop Through Management Groups and Add The Management Group and the Group it Controls
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

            if($htuMngGrpGuidsExt2.ContainsKey($obmGrp.ObjectGUID.ToString()) -eq $true)
            {
                
                #Submit AD3 Managed Group Membership Change
                Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID $obmGrp.ObjectGUID.ToString() -MembershipAction "REMOVE" -MemberGUID $offBoardMbr.ObjectGUID.ToString();

            }
            elseif($obmGrp.DistinguishedName.ToString().Contains($uInformManagementOU) -eq $true -and $htuMngGrpGuidsExt2.ContainsKey($obmGrp.extensionAttribute2.ToString()) -eq $true)
            {
                $obmGrp;
            }
            
        }#End of AD3 Groups Only Check
        
    }#End of MemberOf Foreach

}#End of Offboard User Group Membership Count

