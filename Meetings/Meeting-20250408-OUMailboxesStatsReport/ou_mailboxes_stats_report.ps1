<#
    Title: ou_mailboxes_stats_report.ps1
    Authors: Dean Bunn
    Inspired By: Ben Clark
    Last Edit: 2025-04-08
#>

#Import Exchange Online Management Module. See "commands_for_required_module.ps1" If Not Installed
Import-Module -Name ExchangeOnlineManagement

#Connect to Exchange Online
Connect-ExchangeOnline

#Var for LDAP Search Path
[string]$ldapDeptPath = "LDAP://OU=COE-OU-EDO,OU=COE,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu";

#Var for AD Search Filter
[string]$strFilter = "(&(objectclass=user)(sAMAccountName=*)(!objectClass=organizationalUnit)(!objectClass=computer)(!objectClass=contact)(|(homeMDB=*)(msExchRecipientTypeDetails=*)))";

#Array for Custom Reporting Objects
$arrOUMailboxes = @();

#Var for Report Name
[string]$rptName = "OU_Mailboxes_Stats_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv";

#Var for MS Exchange Mailbox Type Check
[int64]$n64MSExgMailBxType = [int64]::Parse("1000000000");

#Directory Entry for OU's OU
$deOU = New-Object DirectoryServices.DirectoryEntry($ldapDeptPath);

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
$nISDSP = $dsOU.PropertiesToLoad.Add("displayName");
$nISDSP = $dsOU.PropertiesToLoad.Add("mail");
$nISDSP = $dsOU.PropertiesToLoad.Add("givenName");
$nISDSP = $dsOU.PropertiesToLoad.Add("sn");
$nISDSP = $dsOU.PropertiesToLoad.Add("cn");
$nISDSP = $dsOU.PropertiesToLoad.Add("proxyAddresses");
$nISDSP = $dsOU.PropertiesToLoad.Add("distinguishedName");
$nISDSP = $dsOU.PropertiesToLoad.Add("msExchRecipientTypeDetails");
$nISDSP = $dsOU.PropertiesToLoad.Add("userPrincipalName");
$nISDSP = $dsOU.PropertiesToLoad.Add("userAccountControl");

#Search Result Collection to Hold Search Results
[DirectoryServices.SearchResultCollection]$srcResults = $dsOU.FindAll();

#Null Check on Search Results
if($null -ne $srcResults)
{
    #Looping Through Search Results
    foreach($srcResult in $srcResults)
    {

        #Create Custom Reporting Object for OU Account Information
        $cstOUAccnt = new-object PSObject -Property (@{ UserID="";
                                                        AccountStatus="";
                                                        UPN="";
                                                        CN="";
                                                        SN="";
                                                        GivenName="";
                                                        DisplayName=""; 
                                                        Mail="";
                                                        ProxyAddresses="";
                                                        OULocation="";
                                                        LastInteractionTime="";
                                                        LastUserActionTime="";
                                                        MailboxTypeDetail="";
                                                        LastLogoffTime="";
                                                        LastLogonTime="";
                                                        DN="";
                                                    });

        #Load OU Account Information into Custom Reporting Object
        $cstOUAccnt.UserID = $srcResult.Properties["sAMAccountName"][0].ToString().ToLower();
        $cstOUAccnt.UPN = $srcResult.Properties["userPrincipalName"][0].ToString();
        $cstOUAccnt.DN = $srcResult.Properties["distinguishedName"][0].ToString();
        $cstOUAccnt.CN = $srcResult.Properties["cn"][0].ToString();

        #Check SN (Last Name)
        if($srcResult.Properties["sn"].Count -gt 0)
        {
            $cstOUAccnt.SN = $srcResult.Properties["sn"][0].ToString();
        }

        #Check GivenName (First Name)
        if($srcResult.Properties["givenName"].Count -gt 0)
        {
            $cstOUAccnt.GivenName = $srcResult.Properties["givenName"][0].ToString();
        }

        #Check DisplayName 
        if($srcResult.Properties["displayName"].Count -gt 0)
        {
            $cstOUAccnt.DisplayName = $srcResult.Properties["displayName"][0].ToString();
        }

        #Determine OU Location (Reversed DN)
        if([string]::IsNullOrEmpty($cstOUAccnt.DN) -eq $false)
        {
            #Var for Object DN Minus the Departments OU Path Upward 
            [string]$objtDN = $cstOUAccnt.DN.ToLower().Replace(",ou=departments,dc=ou,dc=ad3,dc=ucdavis,dc=edu", "").Replace(",ou=", ";").Replace("cn=", "");

            #Create Array of DN Path
            [array]$arrObjDN = $objtDN.Split(';');

            #Reverse Array
            [array]::Reverse($arrObjDN);

            #Var for Location
            [string]$Location = "";

            foreach($dnPart in $arrObjDN)
            {
                $Location += $dnPart + "\"; 
            }

            #Assign Report OU Location
            $cstOUAccnt.OULocation = $Location.TrimEnd("\");

        }#End OU Location

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

foreach($ouMbx in $arrOUMailboxes)
{
    
    #Pull Exchange Account Mailbox Details
    $exgAcntMbxStats = Get-EXOMailboxStatistics -Identity $ouMbx.UPN -PropertySets All

    #Load Mailbox Type 
    if([string]::IsNullOrEmpty($exgAcntMbxStats.MailboxTypeDetail) -eq $false)
    {
        $ouMbx.MailboxTypeDetail = $exgAcntMbxStats.MailboxTypeDetail.ToString();
    }

    #Load Last Interaction Time
    if([string]::IsNullOrEmpty($exgAcntMbxStats.LastInteractionTime) -eq $false)
    {
        $ouMbx.LastInteractionTime = $exgAcntMbxStats.LastInteractionTime.ToString();
    }

    #Load Last User Action Time
    if([string]::IsNullOrEmpty($exgAcntMbxStats.LastUserActionTime) -eq $false)
    {
        $ouMbx.LastUserActionTime = $exgAcntMbxStats.LastUserActionTime.ToString();
    }

    #Load Last Logoff Time
    if([string]::IsNullOrEmpty($exgAcntMbxStats.LastLogoffTime) -eq $false)
    {
        $ouMbx.LastLogoffTime = $exgAcntMbxStats.LastLogoffTime.ToString();
    }

    #Load Last Logon Time
    if([string]::IsNullOrEmpty($exgAcntMbxStats.LastLogonTime) -eq $false)
    {
        $ouMbx.LastLogonTime = $exgAcntMbxStats.LastLogonTime.ToString();
    }

}

#Close Out DirectoryEntry for OU Object
$deOU.Close();

#Export Reporting Array to CSV
$arrOUMailboxes | Sort-Object -Property UserID | Select-Object -Property UserID,AccountStatus,UPN,CN,SN,GivenName,DisplayName,Mail,MailboxTypeDetail,LastInteractionTime,LastUserActionTime,LastLogoffTime,LastLogonTime,OULocation,DN,ProxyAddresses | Export-Csv -Path $rptName -NoTypeInformation;
