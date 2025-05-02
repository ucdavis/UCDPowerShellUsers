<#
    Title: dns_record_report.ps1
    Authors: Ben Clark and Dean Bunn
    Last Edit: 2025-05-13
#>

#Import Required Modules
#Import-Module ActiveDirectory,DnsServer;

#Var for Distinguised Name of Computer OU
[string]$dnComputerOU ="OU=COE-MAE-CAElab,OU=COE-OU-MAE-Instr,OU=COE-OU-MAE,OU=COE,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu"

#Var for LDAP Search Path
[string]$ldapCmptOUPath = "LDAP://" +  $dnComputerOU;

#Var for AD Search Filter
[string]$strFilter = "(&(objectclass=computer))";

#Array for Custom Reporting Objects
$arrOUComputers = @();

#Var for Report Name
[string]$rptName = "OU_Computers_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv";

#Directory Entry for OU's OU
$deOU = New-Object DirectoryServices.DirectoryEntry($ldapCmptOUPath);

#Directory Searcher for Searching Specified OU
$dsOU = New-Object DirectoryServices.DirectorySearcher($deOU);

#Var for Index Number Supression of Directory Searcher Properties to Load
[int]$nISDSP = 0;

#Configure Directory Searcher
$dsOU.Filter = $strFilter;
$dsOU.SearchScope = [DirectoryServices.SearchScope]::Subtree;
$dsOU.PageSize = 900;

#Supress Displaying the Index Number of Properties Array
$nISDSP = $dsOU.PropertiesToLoad.Add("sAMAccountName");
$nISDSP = $dsOU.PropertiesToLoad.Add("cn");
$nISDSP = $dsOU.PropertiesToLoad.Add("whenCreated");
$nISDSP = $dsOU.PropertiesToLoad.Add("operatingSystem");
$nISDSP = $dsOU.PropertiesToLoad.Add("operatingSystemVersion");
$nISDSP = $dsOU.PropertiesToLoad.Add("name");
$nISDSP = $dsOU.PropertiesToLoad.Add("dNSHostName");
$nISDSP = $dsOU.PropertiesToLoad.Add("distinguishedName");
$nISDSP = $dsOU.PropertiesToLoad.Add("userAccountControl");
$nISDSP = $dsOU.PropertiesToLoad.Add("lastLogon");
$nISDSP = $dsOU.PropertiesToLoad.Add("lastLogonTimestamp");

#Search Result Collection to Hold Search Results
[DirectoryServices.SearchResultCollection]$srcResults = $dsOU.FindAll();

#Null Check on Search Results
if($null -ne $srcResults)
{
    #Looping Through Search Results
    foreach($srcResult in $srcResults)
    {

        #Create Custom Reporting Object for OU Computer Information
        $cstOUCmptr = new-object PSObject -Property (@{ Name="";
                                                        AccountStatus="";
                                                        SAM="";
                                                        CN="";
                                                        DNSHostName="";
                                                        LastLogin=""; 
                                                        LastLoginTimeStamp="";
                                                        OSVersion="";
                                                        OS="";
                                                        Created=""; 
                                                        DN="";
                                                        IP4Addr="";
                                                        IPTimeStamp="";
                                                    });

        #Load OU Computer Information into Custom Reporting Object
        $cstOUCmptr.UserID = $srcResult.Properties["sAMAccountName"][0].ToString().ToLower();
        $cstOUCmptr.DN = $srcResult.Properties["distinguishedName"][0].ToString();
        $cstOUCmptr.CN = $srcResult.Properties["cn"][0].ToString();

        #Check SN (Last Name)
        if($srcResult.Properties["sn"].Count -gt 0)
        {
            $cstOUCmptr.SN = $srcResult.Properties["sn"][0].ToString();
        }

        #Check GivenName (First Name)
        if($srcResult.Properties["givenName"].Count -gt 0)
        {
            $cstOUCmptr.GivenName = $srcResult.Properties["givenName"][0].ToString();
        }

        #Check DisplayName 
        if($srcResult.Properties["displayName"].Count -gt 0)
        {
            $cstOUCmptr.DisplayName = $srcResult.Properties["displayName"][0].ToString();
        }

        #Check Account Status
        if($srcResult.Properties["userAccountControl"].Count -gt 0)
        {
            switch($srcResult.Properties["userAccountControl"][0].ToString())
            {
                '512'{$cstOUAccnt.AccountStatus = "Enabled"; Break;}
                '514'{$cstOUAccnt.AccountStatus = "Disabled"; Break;}
                '544'{$cstOUAccnt.AccountStatus = "Enabled"; Break;}
                '546'{$cstOUAccnt.AccountStatus = "Disabled"; Break;}
                '66048'{$cstOUAccnt.AccountStatus = "Enabled"; Break;}
                '66050'{$cstOUAccnt.AccountStatus = "Disabled"; Break;}
                default{$cstOUAccnt.AccountStatus = "Unknown";}
            }
        }#End of Account Status 

        #Check Mail 
        if($srcResult.Properties["mail"].Count -gt 0)
        {
            $cstOUAccnt.Mail = $srcResult.Properties["mail"][0].ToString();
        }

        #Pull Exchange Recipient Type and Check for Office365 Mailbox
        if($srcResult.Properties["msExchRecipientTypeDetails"].Count -gt 0)
        {
            #Var for Exchange Recipient Type Details
            [Int64]$uERTD = [int64]::Parse($srcResult.Properties["msExchRecipientTypeDetails"][0].ToString());

            #Compare Exchange Type with Office365 Mailbox Type
            if($uERTD -gt $n64MSExgMailBxType)
            {

                #Check ProxyAddresses
                if($srcResult.Properties["proxyAddresses"].count -gt 0)
                {
                    foreach($prxyAddr in $srcResult.Properties["proxyAddresses"])
                    {
                        if($prxyAddr.ToString().ToLower().StartsWith("smtp:"))
                        {
                            $cstOUAccnt.ProxyAddresses += $prxyAddr.ToString().ToLower().Replace("smtp:", "") + " ";
                        }
                    }
                    
                }#End ProxyAddresses

                #Add Custom OU Object to Reporting Array
                $arrOUMailboxes += $cstOUAccnt;

            }#End of Office365 Mailbox Check

        }#End of Office365 Mailbox Check
        
    }#End of $srcResults Foreach

}#End of $srcResults Null Check

#Close Out DirectoryEntry for OU Object
$deOU.Close();



























<#
$arrADComputers = Get-ADComputer -Filter 'Enabled -eq $True' -SearchBase $dnComputerOU -Properties Name,Modified,lastLogonTimestamp

foreach($adCmptr in $arrADComputers)
{

    $adCmptr;

    if([string]::IsNullOrEmpty($adCmptr.lastLogonTimestamp) -eq $false -and 
       $adCmptr.lastLogonTimestamp.ToString() -ne "0" -and 
       $adCmptr.lastLogonTimestamp -ne "9223372036854775807")
    {
        Write-Output ([DateTime]::FromFileTime([long]::Parse($adCmptr.lastLogonTimestamp.ToString())));
    }

#DateTime.FromFileTime((long)srAD3Result.Properties["pwdlastset"][0]).ToString();
#"9223372036854775807"

}
#>
#(Get-DnsServerResourceRecord -ComputerName "128.120.42.42" -zonename "ad3.ucdavis.edu" -name "coe-mae-cae02.ou").DistinguishedName

<#
$TargetOU="OU=COE-MAE-CAElab,OU=COE-OU-MAE-Instr,OU=COE-OU-MAE,OU=COE,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu"
$Computers = Get-ADComputer -Filter 'Enabled -eq $True' -SearchBase $TargetOU -Properties Name, Modified

foreach ($item in $Computers){
#    Write-Host $item.Name, $item.Modifie, Enabled
    $oudnsname=$item.Name +".ou"
    Get-DnsServerResourceRecord -ComputerName "128.120.42.42" -zonename "ad3.ucdavis.edu" -rrtype "A" -Name $oudnsname 
    }

#>