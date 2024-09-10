<#
    Title: home_directories.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-09-09
#>

#Var for Home Directories Folder Location
[string]$UHDFldrLoc = "c:\Users";

#Var for Report Date
[string]$rptDate = (Get-Date).ToString("yyyy-MM-dd"); 

#Var for Host
[string]$hdHost = $env:COMPUTERNAME;

#Var for Report Name
[string]$rptName = ".\" + $hdHost + "_Home_Directories_on_" + $rptDate + ".csv";

#Reporting Array
$arrReporting = @();

#Var for Progress Indicator
$prgresIndctr = 0;

#HashTable of Home Directory Names to Ignore
$htHDIgnore = @{};
$htHDIgnore.Add("administrator","1");
$htHDIgnore.Add("public","1");

#Var for AD Domain
$ad3Domain = "ad3.ucdavis.edu";

#Array of Addition User Properties to Retrieve
[string[]]$arrAdtUsrProps = "lastLogonTimestamp","displayName";

#Pull All the Directories Under the Home Directories Folder
$UHDirctories = Get-ChildItem -Path $UHDFldrLoc -Directory;

#Loop Through Child Directories
foreach($uhdDir in $UHDirctories)
{

    #Increment Progress Indicator
    $prgresIndctr++;

    #Display Currently Working on Folder Number
    Write-Output ("Serving Number " + $prgresIndctr.ToString());

    if($htHDIgnore.ContainsKey($uhdDir.Name.ToLower()) -eq $false -and $uhdDir.Name.ToString() -match '^[a-zA-Z0-9\-\.]*$')
    {

        #Custom Object for Home Directory Profile Reporting
        $cstFldrInfo = New-Object PSObject -Property(@{ DirName="";
                                                        ProfileLoc="";
                                                        ProfileHDDate="";
                                                        ADUserID="";
                                                        ADUserUPN="";
                                                        ADUserEnabled="";
                                                        ADUserFullName="";
                                                        ADUserLastLoginTimeStamp="";
                                                    });


        #Set Name of Directory
        $cstFldrInfo.DirName = $uhdDir.Name;

        #Set Full Profile Location
        $cstFldrInfo.ProfileLoc = $uhdDir.FullName;

        #Set Home Directory Last Write Time
        $cstFldrInfo.ProfileHDDate = $uhdDir.LastWriteTime.ToString('yyyy-MM-dd');

        #Pull AD3 User Account
        $ad3UsrAcnt = Get-ADUser -Identity $uhdDir.Name.ToLower() -Server $ad3Domain -Properties $arrAdtUsrProps;

        #Set AD User Full Name
        if([string]::IsNullOrEmpty($ad3UsrAcnt.SamAccountName) -eq $false)
        {
            #Set AD User ID
            $cstFldrInfo.ADUserID = $ad3UsrAcnt.SamAccountName;
            $cstFldrInfo.ADUserUPN = $ad3UsrAcnt.UserPrincipalName;
            $cstFldrInfo.ADUserEnabled = $ad3UsrAcnt.Enabled;

            #Set AD User Full Name
            if([string]::IsNullOrEmpty($ad3UsrAcnt.displayName) -eq $false)
            {
                $cstFldrInfo.ADUserFullName = $ad3UsrAcnt.displayName;
            }
            else
            {
                $cstFldrInfo.ADUserFullName = $ad3UsrAcnt.GivenName + " " + $ad3UsrAcnt.Surname;
            }

            #Set Last Login TimeStamp
            if($null -ne $ad3UsrAcnt.lastLogonTimestamp)
            {
                $cstFldrInfo.ADUserLastLoginTimeStamp = [DateTime]::FromFileTime($ad3UsrAcnt.lastLogonTimestamp).ToString('yyyy-MM-dd')
            }

        }
    
        #Add Custome User Directory Information to Reporting Array
        $arrReporting += $cstFldrInfo;

        #Clear AD3 User Information
        $ad3UsrAcnt = $null;

    }#End of Ignore Directories Checks
    
}#End $UHDirectories 

#Export Reporting Array to CSV
$arrReporting | Sort-Object -Property DirName | Select-Object -Property DirName,ProfileHDDate,ProfileLoc,ADUserID,ADUserUPN,ADUserEnabled,ADUserFullName,ADUserLastLoginTimeStamp | Export-Csv -Path $rptName -NoTypeInformation;