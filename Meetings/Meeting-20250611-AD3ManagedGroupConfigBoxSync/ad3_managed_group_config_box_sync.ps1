<#
    Title: ad3_managed_group_config_box_sync.ps1
    Authors: Dean Bunn
    Inspired By: Ben Clark
    Last Edit: 2025-06-11
#>

#Var for AD3 Managed Group Guid
[string]$ad3MgrGrpGuid = "029bc98b-caa4-4f9b-9b6b-3133f3644cfd"

#Import Custom uInform API Module 
Import-Module .\uInformAPI.psm1

#Custom Object for UC Davis API Information
$global:UCDAPIInfo = new-object PSObject -Property (@{ uinform_public_key=""; uinform_private_key=""; uinform_url_base="";});

#Load Public and Private Keys for uInform API Access
$UCDAPIInfo.uinform_public_key = Get-Secret -Name "uInformAPI-Pubkey" -AsPlainText -Vault UCDAccounts;
$UCDAPIInfo.uinform_private_key = Get-Secret -Name "uInformAPI-Pvtkey" -AsPlainText -Vault UCDAccounts;
$UCDAPIInfo.uinform_url_base = "https://ws.uinform.ucdavis.edu/";

#Null\Empty Checks on uInform API Values
if([string]::IsNullOrEmpty($UCDAPIInfo.uinform_public_key) -eq $false -and [string]::IsNullOrEmpty($UCDAPIInfo.uinform_public_key) -eq $false)
{
    #First Pull Managed Group to Get Required Values for Put Submission
    $uCntMngGrp = Get-uInformAPIAD3ManagedGroupGeneralInfo -GroupGUID $ad3MgrGrpGuid;

    #Var for Max Group Membership Number
    [int]$nMaxGrpMbr = $null;

    if([string]::IsNullOrEmpty($uCntMngGrp.maxMembers) -eq $false)
    {
        $nMaxGrpMbr = [int]$uCntMngGrp.maxMembers
    }
   
    #Submit Config Box Sync Request to uInform API
    Submit-uInformAPIAD3ManagedGroupConfigBoxSync -GroupGUID $ad3MgrGrpGuid -GrpExtensionAttr6 "UCDBoxSync" -GrpDisplayName $uCntMngGrp.displayName -GrpDescription $uCntMngGrp.description -GrpMaxMbr $nMaxGrpMbr;
    
}
