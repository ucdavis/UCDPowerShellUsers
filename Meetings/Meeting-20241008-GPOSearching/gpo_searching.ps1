<#
    Title: gpo_searching.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-10-08
#>

#Import Active Directory and Group Policy Modules
Import-Module ActiveDirectory;
Import-Module GroupPolicy;

#Array of Search Terms to Check GPOs for
$arrGPOSearchTerms = @("COEAdmin-Ben","128.120.253.107","COE-ADAutomation-Devs");

#Var for Department OU Search Path
[string]$dptOUSearchPath = "ou=coe-ou-it-workstations,ou=coe-ou-it,ou=coe,ou=departments,dc=ou,dc=ad3,dc=ucdavis,dc=edu";

#Var for GPOs Domain FQDN
[string]$dmnGPOFDQN = "ou.ad3.ucdavis.edu";

#HashTable for Unique GPO IDs
$htGPOIDs = @{};

#Pull Department OUs
$dptOUs = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $dptOUSearchPath -server $dmnGPOFDQN;

#Check Each OUs for GPOs Assigned
foreach($dptOU in $dptOUs)
{
  
    #Pull Unique GPO IDs
    if($dptOU.LinkedGroupPolicyObjects.Count -gt 0)
    {

        foreach($lnkGPO in $dptOU.LinkedGroupPolicyObjects)
        {
            #Remove Unneeded GPO Resource Data to Get Only the GPO GUID ID
            $gpoID = $lnkGPO.ToString().Split(',')[0].ToString().Replace("cn={","").Replace("}","");
            
            #Check for Unique GPO ID
            if([string]::IsNullOrEmpty($gpoID) -eq $false -and $htGPOIDs.ContainsKey($gpoID) -eq $false)
            {
                $htGPOIDs.Add($gpoID,"1");
            }

        }#End of Linked Group Policy Objects Foreach

    }#End of Linked Group Policy Objects Count Check

}#End of $dptOUs Foreach

#Null Check on GPO IDs
if($htGPOIDs.Count -gt 0)
{
    #Loop Through Unique GPO IDs
    foreach($gpID in $htGPOIDs.Keys)
    {
        #Convert String to Guid
        $guidGPOID = [Guid]$gpID;

        #Pull Group Policy Object
        $gpo = Get-GPO -Guid $guidGPOID -Server $dmnGPOFDQN -Domain $dmnGPOFDQN;

        #Pull GPO HTML Report
        [string]$gpoHTMLReport = Get-GPOReport -Guid $guidGPOID -ReportType Html -Server $dmnGPOFDQN -Domain $dmnGPOFDQN;

        #Loop Through Each Search Term and Look for it in the HTML Report of GPO
        foreach($gpoSrchTerm in $arrGPOSearchTerms)
        {
            #Check for Search Term in GPO HTML Report Content
            if($gpoHTMLReport.ToLower().Contains($gpoSrchTerm.ToString().ToLower()) -eq $true)
            {
                Write-Output ("`r`n Found search term " + $gpoSrchTerm + " in " + $gpo.DisplayName);
            }

        }#End of Search Terms Foreach

    }#End of GPO IDs Foreach

}#End of GPO ID Count Check

#Line Break to Easy Viewing
Write-Output "`r`n";

