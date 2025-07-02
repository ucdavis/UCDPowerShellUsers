<#
    script: find-hs-split-appointments.ps1
#>

#Var for IAM Payroll Department Code
$ucdDeptCode = "024036";

#Pull Root AD Domain
$deADRoot = [DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().RootDomain.GetDirectoryEntry();

#Intitiate Directory Searcher
[DirectoryServices.DirectorySearcher]$dsSearcher = New-Object DirectoryServices.DirectorySearcher($deADRoot);
$dsSearcher.SearchScope = [DirectoryServices.SearchScope]::Subtree;
$dsSearcher.PageSize = 900;
[void]$dsSearcher.PropertiesToLoad.Add("sAMAccountName");
[void]$dsSearcher.PropertiesToLoad.Add("userPrincipalName");
[void]$dsSearcher.PropertiesToLoad.Add("DisplayName");
[void]$dsSearcher.PropertiesToLoad.Add("extensionAttribute14");
[void]$dsSearcher.PropertiesToLoad.Add("extensionAttribute9");

#Search for Health System Related Users
$dsSearcher.Filter = "(&(objectclass=user)(extensionAttribute14=*;HS*)(extensionAttribute9=*" + $ucdDeptCode + "*))";

#Search for Health Related Users
[DirectoryServices.SearchResultCollection]$srchRlstHealthMembers = $dsSearcher.FindAll();

foreach($srchRslt in $srchRlstHealthMembers)
{
    #Don't Display the HS Only Members. We want Split Appointments
    if($srchRslt.Properties["extensionAttribute14"][0].ToString().Trim().ToLower() -ne ";hs")
    {
        [string]$HSUser = "User ID: " + $srchRslt.Properties["sAMAccountName"][0].ToString().ToLower() + `
                      ", Display Name: " + $srchRslt.Properties["DisplayName"][0].ToString() + `
                      ", UPN: " + $srchRslt.Properties["userPrincipalName"][0].ToString().ToLower();

        Write-Output $HSUser;
    }

}

#Close Out Directory Entry for Domain
$deADRoot.Close();