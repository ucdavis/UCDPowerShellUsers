<#
    Title: rosetta-client-demo.ps1
    Authors: Dean Bunn and Wilson Miller
    Last Edit: 2026-08-06
#>

#Custom Object for Rosetta API Worker Config Values
$rosettaAPIConfig = [PSCustomObject]@{
                                        BaseUrl            =  Get-Secret -Name "Rosetta-Base-Url" -AsPlainText -Vault "UCD-Identities"
                                        OAuthUrl           =  Get-Secret -Name "Rosetta-OAuth-Url" -AsPlainText -Vault "UCD-Identities"
                                        ClientID           =  Get-Secret -Name "Rosetta-Client-ID" -AsPlainText -Vault "UCD-Identities"
                                        ClientSecret       =  Get-Secret -Name "Rosetta-Client-Secret" -AsPlainText -Vault "UCD-Identities"
                                        Scopes             =  Get-Secret -Name "Rosetta-Client-Scopes" -AsPlainText -Vault "UCD-Identities"
                                    }
                           
#Import the Custom Rosetta Library
Add-Type -Path ".\UCD.COE.Rosetta.Client.dll"

#Initiate Rosetta API Worker
$rosettaWrkr = [UCD.COE.Rosetta.Client.RosettaAPIWorker]::new($rosettaAPIConfig.BaseUrl,
                                                              $rosettaAPIConfig.OAuthUrl,
                                                              $rosettaAPIConfig.ClientID,
                                                              $rosettaAPIConfig.ClientSecret,
                                                              $rosettaAPIConfig.Scopes);

#Pull All Currently Assigned Job Type IDs
$arrRosettaJobTypeIDs = $rosettaWrkr.GetRosettaJobTypeIDs();
$arrRosettaJobTypeIDs

#Pull Employee Associations by Department Code
$arrEmployeeAssocs = $rosettaWrkr.GetEmployeeAssociationsBySearchTerm([UCD.COE.Rosetta.Client.RosettaAPIWorker+EmployeeSearchBy]::departmentid,"024000");
$arrEmployeeAssocs;

#Pull Student Associations by Major Code
$arrStudentAssocs = $rosettaWrkr.GetStudentAssociationsBySearchTerm([UCD.COE.Rosetta.Client.RosettaAPIWorker+StudentSearchBy]::majorcode,"GBIM");
$arrStudentAssocs;

#Pull Individual by Login ID
$arrPeople = $rosettaWrkr.GetPeopleBySearchTerm([UCD.COE.Rosetta.Client.RosettaAPIWorker+PeopleSearchBy]::loginid,"dbunn");

#PeopleSearchBy Enum:
#iamid,
#loginid,
#email,
#employeeid,
#studentid,
#mailid,
#department

#Dictionary of Unique IAM IDs
$dictIAMIDs = [System.Collections.Generic.Dictionary[string, int]]::new();
$dictIAMIDs.Add("1000024325",1);
$dictIAMIDs.Add("1000011001",1);
$dictIAMIDs.Add("1000138242",1);
$dictIAMIDs.Add("1000007148",1);

#Lookup Large Amount of Unique IAM IDs using an Asynchronous Function 
$arrPeople = $rosettaWrkr.MassPeopleLookupByIAMIDs($dictIAMIDs).GetAwaiter().GetResult();

foreach($ucdPeep in $arrPeople)
{
    #Display General People Information
    $ucdPeep;

    #Display Employee Associations If Any
    foreach($empAssoc in $ucdPeep.lEmployeeAssociations)
    {
        $empAssoc;
    }

    #Display Student Associations If Any
    foreach($stdntAssoc in $ucdPeep.lStudentAssociations)
    {
        $stdntAssoc;
    }

}
