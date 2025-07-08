<#
    Title: find-hs-split-appointments.ps1
    Authors: Ben Clark and Dean Bunn
    Last Edit: 2025-07-08
#>

#Array for IAM Payroll Department Codes
$ucdDeptCodes = @("024036","027025");

#Pull Root AD Domain
$deADRoot = [DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().RootDomain.GetDirectoryEntry();

#Intitiate Directory Searcher
[DirectoryServices.DirectorySearcher]$dsSearcher = New-Object DirectoryServices.DirectorySearcher($deADRoot);
$dsSearcher.SearchScope = [DirectoryServices.SearchScope]::Subtree;
$dsSearcher.PageSize = 900;
[void]$dsSearcher.PropertiesToLoad.Add("sAMAccountName");
[void]$dsSearcher.PropertiesToLoad.Add("userPrincipalName");
[void]$dsSearcher.PropertiesToLoad.Add("displayName");
[void]$dsSearcher.PropertiesToLoad.Add("extensionAttribute14");
[void]$dsSearcher.PropertiesToLoad.Add("extensionAttribute9");

#Loop Through Each UCD Department Code
foreach($ucdDeptCode in $ucdDeptCodes)
{
    #Search for Health System Related Users
    $dsSearcher.Filter = "(&(objectclass=user)(extensionAttribute14=*;HS*)(extensionAttribute9=*" + $ucdDeptCode + "*))";

    #Search for Health Related Users
    [DirectoryServices.SearchResultCollection]$srchRlstHealthMembers = $dsSearcher.FindAll();

    #Loop Through the Search Results
    foreach($srchRslt in $srchRlstHealthMembers)
    {
        #Don't Display the HS Only Members. We want Split Appointments
        if($srchRslt.Properties["extensionAttribute14"][0].ToString().Trim().ToLower() -ne ";hs")
        {
            [string]$HSUser = "User ID: " + $srchRslt.Properties["sAMAccountName"][0].ToString().ToLower() + `
                        ", Display Name: " + $srchRslt.Properties["displayName"][0].ToString() + `
                        ", UPN: " + $srchRslt.Properties["userPrincipalName"][0].ToString().ToLower();

            Write-Output $HSUser;
        }

    }

}#End of $ucdDeptCodes Foreach

#Close Out Directory Entry for Domain
$deADRoot.Close();