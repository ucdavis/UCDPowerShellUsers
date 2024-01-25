<#
    Title: ucd-iam-demo.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-01-24
#>

#Var for Config Settings
$cnfgSettings = $null; 

#Check for Settings File 
if((Test-Path -Path .\config.json) -eq $true)
{
    #Import Json Configuration File
    $cnfgSettings =  Get-Content -Raw -Path .\config.json | ConvertFrom-Json;
}
else
{
    #Create Blank Config Object and Export to Json File
    $blnkConfig = new-object PSObject -Property (@{ IAM_Base_URL="https://xxxxxxxx.ucdavis.edu/api/iam/"; 
                                                    IAM_Key="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
                                                    IAM_MyID="XXXXXXXXXXXXXX";
                                                    Departments=@(@{Dept_Name="MyDepartment1";
                                                                    Dept_Code="000000";},
                                                                  @{Dept_Name="MyDepartment2";
                                                                    Dept_Code="000000";}
                                                                );
                                                  });

    
    $blnkConfig | ConvertTo-Json -Depth 4 | Out-File .\config.json;

    #Exit Script
    exit;
}


#Loop Through Each Department Listed in Config File
foreach($dpt in $cnfgSettings.Departments)
{

    #Array for Custom Payroll Association Objects
    $arrCstPRAssociations = @();

    #Var for IAM URL Pull Payroll Associations By Department Code
    [string]$iam_url_prassociations = $cnfgSettings.IAM_Base_URL + "associations/pps/search?key=" + $cnfgSettings.IAM_Key + "&v=1.0&apptDeptCode=" + $dpt.Dept_Code;

    #Pull Payroll Associations for Department Code
    $iamPRAssociations = (Invoke-RestMethod -ContentType "application/json" -Uri $iam_url_prassociations).responseData.results;

    foreach($iamPR in $iamPRAssociations)
    {
        #Create Custom Reporting Object for PR Association
        $cstPRAssoc = new-object PSObject -Property (@{ iamID=""; 
                                                        UserID=""; 
                                                        DisplayName=""; 
                                                        EmailAddress="";
                                                        Department=""; 
                                                        Title=""; 
                                                        TitleCode=""; 
                                                        PositionType="";
                                                        PositionTypeCode=""; 
                                                        EmployeeClass="";
                                                        EmployeeClassDescription="";
                                                        AssociationStartDate="";});

        #Load Custom Object Payroll Association Values
        $cstPRAssoc.iamID = $iamPR.iamID;
        $cstPRAssoc.Department = $iamPR.apptDeptOfficialName;
        $cstPRAssoc.TitleCode = "'" + $iamPR.titleCode;
        $cstPRAssoc.Title = $iamPR.titleOfficialName;
        $cstPRAssoc.PositionTypeCode = $iamPR.positionTypeCode;
        $cstPRAssoc.PositionType = $iamPR.positionType;
        $cstPRAssoc.EmployeeClass = $iamPR.emplClass;
        $cstPRAssoc.EmployeeClassDescription = $iamPR.emplClassDesc;
        $cstPRAssoc.AssociationStartDate = $iamPR.assocStartDate;

        #Var for IAM URL for Basic Information about Individual Member
        [string]$iam_url_basic = $cnfgSettings.IAM_Base_URL + "people/" + $cstPRAssoc.iamID + "?key=" + $cnfgSettings.IAM_Key + "&v=1.0";

        #Pull Basic Information about UCD Member by IAM ID
        foreach($iamRslt in (Invoke-RestMethod -ContentType "application/json" -Uri $iam_url_basic).responseData.results)
        {
            #Load Basic User Information
            $cstPRAssoc.UserID = $iamRslt.userId;
            $cstPRAssoc.DisplayName = $iamRslt.dFullName;
            $cstPRAssoc.EmailAddress = $iamRslt.campusEmail;

        }

        #Add Custom Object to Reporting Array
        $arrCstPRAssociations += $cstPRAssoc;

    }#End of iamPRAssociations Foreach

    #Var for Reporting File with Dept Code
    [string]$rptFileName = "IAM-Dept-" +  $dpt.Dept_Code  + "-Payroll-Associations-" + (Get-Date).ToString("yyyy-MM-dd") + ".csv";

    #Export Custom Payroll Associations Listing for Dept Code
    $arrCstPRAssociations | Select-Object -Property UserID,DisplayName,EmailAddress,Title,TitleCode,PositionType,PositionTypeCode,EmployeeClass,EmployeeClassDescription,AssociationStartDate,Department | Export-Csv -Path .\$rptFileName -NoTypeInformation;

}#End of Departments Foreach Pulling IAM Payroll Associations
#>

#############################################################
# Use for Pulling Individuals Info
#############################################################

#Var for URL of Individual's IAM Basic Information
[string]$iam_url_indv_basicinfo = $cnfgSettings.IAM_Base_URL + "people/" + $cnfgSettings.IAM_MyID + "?key=" + $cnfgSettings.IAM_Key + "&v=1.0";

#Var for URL of Individual's IAM Associations
[string]$iam_url_indv_affiliations = $cnfgSettings.IAM_Base_URL + "people/affiliations/" + $cnfgSettings.IAM_MyID + "?key=" + $cnfgSettings.IAM_Key + "&v=1.0";

#Var for URL of Individual's IAM Contact Info
[string]$iam_url_indv_contact = $cnfgSettings.IAM_Base_URL + "people/contactinfo/" + $cnfgSettings.IAM_MyID + "?key=" + $cnfgSettings.IAM_Key + "&v=1.0";

#Var for URL of Individual's IAM Payroll Associations
[string]$iam_url_indv_payroll = $cnfgSettings.IAM_Base_URL + "associations/pps/" + $cnfgSettings.IAM_MyID + "?key=" + $cnfgSettings.IAM_Key + "&v=1.0";


#Display Individual IAM Information
(Invoke-RestMethod -ContentType "application/json" -Uri $iam_url_indv_basicinfo).responseData.results;

Write-Output " ";
Write-Output "===============================";
Write-Output " ";

#Display Individual IAM Associations
(Invoke-RestMethod -ContentType "application/json" -Uri $iam_url_indv_affiliations).responseData.results;

Write-Output " ";
Write-Output "===============================";
Write-Output " ";

#Display Individual IAM Contact Information
(Invoke-RestMethod -ContentType "application/json" -Uri $iam_url_indv_contact).responseData.results;

Write-Output " ";
Write-Output "===============================";
Write-Output " ";

#Display Individual IAM Payroll Associations
(Invoke-RestMethod -ContentType "application/json" -Uri $iam_url_indv_payroll).responseData.results;


#Information About Requesting Access to IAM
#start-process https://iet-ws.ucdavis.edu/iet-ws/#/home