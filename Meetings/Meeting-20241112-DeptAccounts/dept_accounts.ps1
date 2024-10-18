<#
    Title: dept_accounts.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-11-12
#>

#Array of Department Codes
$deptCodes = @("024025");

#Import Active Directory Module
Import-Module ActiveDirectory;

#Var for AD Fully Qualified Domain Name
[string]$dmnFQDN = "ad3.ucdavis.edu";

#Var for Search Base
[string]$adSrchBase = "OU=ucdUsers,DC=ad3,DC=ucdavis,DC=edu";

#Array of Addition Group Properties to Retrieve
[string[]]$arrUsrProps = "displayName","extensionAttribute5","extensionAttribute7";

#Var for Report Name
[string]$rptName = "Department_Accounts_" + (Get-Date).ToString("yyyy-MM-dd") + ".csv";

#Array for Department Accounts
$arrDeptAccounts = @();

#HashTable of Unique Department Account IDs
$htDptAcntGUIDs = @{};

#HashTable of Unique Account Owner IAM IDs
$htOwnerIAMIDs = @{};

#Loop Through Each Department Code and Pull Department Accounts Associated with it
foreach($deptCode in $deptCodes)
{

    #Var for LDAP Filter
    [string]$adLDAPFilter = "(&(objectclass=user)(extensionAttribute11=D)(|(department=" + $deptCode + ")(departmentNumber=" + $deptCode + ")(extensionAttribute9=*" + $deptCode + "*)))";

    #Query AD for UCD Department Accounts
    foreach($adDeptAccnt in (Get-ADUser -LDAPFilter $adLDAPFilter -SearchBase $adSrchBase -server $dmnFQDN -Properties $arrUsrProps))
    {

        #Check HashTable for Unique Guids (Prevent Duplicates If More than Department Code Searched for)
        if($htDptAcntGUIDs.ContainsKey($adDeptAccnt.ObjectGUID.ToString()) -eq $false)
        {

            #Add Department Account Guid to HashTable
            $htDptAcntGUIDs.Add($adDeptAccnt.ObjectGUID.ToString(),"1");

            #Create Custom Reporting Object for Department Account Information
            $cstDptAccnt = new-object PSObject -Property (@{ UserID="";
                                                             UPN="";
                                                             Enabled="";
                                                             DisplayName=""; 
                                                             EmailHost="";
                                                             DepartmentCode="";
                                                             OwnerIAMID=""; 
                                                             OwnerUserName="";
                                                             OwnerUPN="";
                                                            });

            #Set Basic Properties
            $cstDptAccnt.UserID = $adDeptAccnt.SamAccountName;
            $cstDptAccnt.UPN = $adDeptAccnt.UserPrincipalName;
            $cstDptAccnt.Enabled = $adDeptAccnt.Enabled;
            $cstDptAccnt.DepartmentCode = $deptCode;
            
            #Set Display Name
            if([string]::IsNullOrEmpty($adDeptAccnt.DisplayName) -eq $false)
            {
                $cstDptAccnt.DisplayName = $adDeptAccnt.DisplayName
            }

            #Set Email Host
            if([string]::IsNullOrEmpty($adDeptAccnt.extensionAttribute5) -eq $false `
              -and $adDeptAccnt.extensionAttribute5.ToString().Contains("@") -eq $true)
            {

                if($adDeptAccnt.extensionAttribute5.ToString().ToLower().Contains("@ad3.ucdavis.edu") -eq $true)
                {
                    $cstDptAccnt.EmailHost = "Office365";
                }
                elseif($adDeptAccnt.extensionAttribute5.ToString().ToLower().Contains("@gmx.ucdavis.edu") -eq $true)
                {
                    $cstDptAccnt.EmailHost = "DavisMail";
                }
                else
                {
                    $cstDptAccnt.EmailHost = $adDeptAccnt.extensionAttribute5.ToString().Split("@")[1];
                }
                
            }

            #Set Owner IAM ID
            if([string]::IsNullOrEmpty($adDeptAccnt.extensionAttribute7) -eq $false)
            {
                #Add Owner IAM ID  
                $cstDptAccnt.OwnerIAMID = $adDeptAccnt.extensionAttribute7.ToString().Trim();

                #Check for Unique Owner IDs to Lookup Later
                if($htOwnerIAMIDs.ContainsKey($adDeptAccnt.extensionAttribute7.ToString().Trim()) -eq $false)
                {
                    $htOwnerIAMIDs.Add($adDeptAccnt.extensionAttribute7.ToString().Trim(),"1");
                }

            }

            #Add Custom Object to Reporting Array
            $arrDeptAccounts += $cstDptAccnt;

        }#End of Unique Object Guid Check
        
    }#End of Foreach AD Department Account

}#End of Department Codes Foreach

#Query AD for Department Account Owner Information
foreach($ownerkey in $htOwnerIAMIDs.Keys)
{
    
    #Var for IAM ID LDAP Filter
    [string]$adLDAPFilterIAM = "(&(objectclass=user)(extensionAttribute7=" + $ownerkey + ")(!(extensionAttribute11=D)))";

    #Query AD for User Accounts with IAM ID But not Listed as Departmental
    foreach($adOwnrAccnt in (Get-ADUser -LDAPFilter $adLDAPFilterIAM -SearchBase $adSrchBase -server $dmnFQDN -Properties $arrUsrProps))
    {
    
       #Check Returned Account for the Data We Need for Report
       if([string]::IsNullOrEmpty($adOwnrAccnt.DisplayName) -eq $false -and [string]::IsNullOrEmpty($adOwnrAccnt.UserPrincipalName) -eq $false)
        {
            #Loop Through Our Report and Check IAM ID
            foreach($uDptAcnt in $arrDeptAccounts)
            {
                #If Owner IDs Match Then Set Owner Information for Report
                if($uDptAcnt.OwnerIAMID -eq $ownerkey)
                {
                    $uDptAcnt.OwnerUserName = $adOwnrAccnt.DisplayName;
                    $uDptAcnt.OwnerUPN = $adOwnrAccnt.UserPrincipalName;
                }

            }#End of $arrDeptAccounts Foreach

        }#End of Null\Empty Checks on Owners DisplayName and UPN

    }#End of Query AD for Owner Account

}#End of $htOwnerIAMIDs.Keys Foreach

#Export Reporting Array to CSV
$arrDeptAccounts | Sort-Object -Property UserID | Select-Object -Property UserID,UPN,Enabled,DisplayName,EmailHost,DepartmentCode,OwnerIAMID,OwnerUserName,OwnerUPN | Export-Csv -Path $rptName -NoTypeInformation;









