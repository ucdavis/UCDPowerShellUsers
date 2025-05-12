<#
    Title: dns_record_report.ps1
    Authors: Ben Clark and Dean Bunn
    Last Edit: 2025-05-13
#>

#Import Required Modules
Import-Module ActiveDirectory,DnsServer;

#Array of Computer OU Paths
$arrComputerOUs = @("OU=COE-MAE-CAElab,OU=COE-OU-MAE-Instr,OU=COE-OU-MAE,OU=COE,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu",
                    "OU=COE-OU-CEE-Instruction,OU=COE-OU-CEE,OU=COE,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu",
                    "OU=COE-ECE-KEMPER,OU=COE-OU-ECE-Instr,OU=COE-OU-ECE,OU=COE,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu",
                    "OU=COE-BAE-Instr,OU=COE-OU-BAE,OU=COE,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu");

#Var for AD DNS Server 
[string]$dnsADServer = "128.120.42.42";

#Var for AD DNS Zone Name
[string]$dnsZoneName = "ad3.ucdavis.edu";

#Array for Custom Reporting Objects
$arrRptComputers = @();

#Array for Custom Reporting No DNS Records
$arrRptNoDNSRecords = @();

#Var for Report Name
[string]$rptName = "DNS_Record_Report_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv";

#Var for No DNS Record Report Name
[string]$rptNameNoDNS = "No_DNS_Record_Report_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv";

#Go Through Each Submitted OU
foreach($dnComputerOU in $arrComputerOUs)
{
    #Query AD for Computers
    $arrADComputers = Get-ADComputer -Filter 'Enabled -eq $True' -SearchBase $dnComputerOU -Properties Name,Modified,lastLogonTimestamp,whenCreated,operatingSystem;

    foreach($adCmptr in $arrADComputers)
    {
        #Var for Last Login TimeStamp
        [datetime]$dtLastLoginTimeStamp = [datetime]::MinValue;

        #Determine Last Login TimeStamp
        if([string]::IsNullOrEmpty($adCmptr.lastLogonTimestamp) -eq $false -and 
        $adCmptr.lastLogonTimestamp.ToString() -ne "0" -and 
        $adCmptr.lastLogonTimestamp -ne "9223372036854775807")
        {
            $dtLastLoginTimeStamp = [DateTime]::FromFileTime([long]::Parse($adCmptr.lastLogonTimestamp.ToString()));
        }

        #Null\Empty Check on DNS Host Name in AD
        if([string]::IsNullOrEmpty($adCmptr.DNSHostName) -eq $false)
        {
            #Var for DNS Name to Lookup
            [string]$dnsADCmptrName = $adCmptr.DNSHostName.ToString().Replace($dnsZoneName,"").TrimEnd(".");

            #Pull DNS Records for Computer
            $arrDNSRecords = Get-DnsServerResourceRecord -ComputerName $dnsADServer -zonename $dnsZoneName -rrtype "A" -Name $dnsADCmptrName;

            #Null\Empty Check on DNS Records
            if($null -ne $arrDNSRecords -and $arrDNSRecords.Count -gt 0)
            {
                #Loop Through DNS Records
                foreach($dnsRcd in $arrDNSRecords)
                {
                    #Create Custom Computer Reporting Object
                    $cstCmptr = [PSCustomObject]@{
                                                    ComputerName    = $adCmptr.Name
                                                    DNSHostName     = $adCmptr.DNSHostName
                                                    OSName          = $adCmptr.OperatingSystem
                                                    WhenCreated     = $adCmptr.whenCreated
                                                    Modified        = $adCmptr.Modified
                                                    DN              = $adCmptr.DistinguishedName
                                                    LastLoginTS     = $dtLastLoginTimeStamp.ToString()
                                                    IPAddress       = $dnsRcd.RecordData.IPv4Address
                                                    IPAddrTimeStamp = $dnsRcd.TimeStamp
                                                    DNSRecordOld    = $false
                                                };
                    
                    #Check for Old DNS Records
                    if($null -ne $dnsRcd.TimeStamp -and $dtLastLoginTimeStamp.AddMonths(-1) -gt [datetime]::Parse($dnsRcd.TimeStamp))
                    {
                        $cstCmptr.DNSRecordOld = $true;
                    }

                    #Add Custom Object to Reporting Array
                    $arrRptComputers += $cstCmptr;

                }#End of $arrDNSRecords Foreach

            }
            else 
            {
                
                #Create Custom Reporting Object for No DNS Record
                $cstNoDNS = [PSCustomObject]@{
                                                ComputerName    = $adCmptr.Name
                                                DNSHostName     = $adCmptr.DNSHostName
                                                OSName          = $adCmptr.OperatingSystem
                                                WhenCreated     = $adCmptr.whenCreated
                                                DN              = $adCmptr.DistinguishedName
                                                LastLoginTS     = $dtLastLoginTimeStamp.ToString()
                };

                #Add Custom Object to No DNS Reporting Array
                $arrRptNoDNSRecords += $cstNoDNS;

            }#End of Null\Empty Check on DNS Records

        }#End of Null\Empty Checks on DNS Host Name

    }#End of $arrComputerOUs Foreach

}#End of $arrComputerOUs Foreach

#Export Reporting Array to CSV
$arrRptComputers | Sort-Object -Property ComputerName | Select-Object -Property ComputerName,DNSHostName,OSName,WhenCreated,Modified,LastLoginTS,IPAddress,IPAddrTimeStamp,DNSRecordOld,DN | Export-Csv -Path $rptName -NoTypeInformation;

#Export No DNS Listing to CSV
$arrRptNoDNSRecords | Sort-Object -Property ComputerName | Select-Object -Property ComputerName,DNSHostName,OSName,WhenCreated,LastLoginTS,DN | Export-Csv -Path $rptNameNoDNS -NoTypeInformation;













