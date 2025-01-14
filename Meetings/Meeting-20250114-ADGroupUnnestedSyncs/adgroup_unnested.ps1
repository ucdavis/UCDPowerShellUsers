<#
    Title: adgroup_unnested.ps1
    Authors: Dean Bunn
    Last Edit: 2023-03-30
#>

#Var for Config Settings
$cnfgSettings = $null; 

#Check for Settings File 
if((Test-Path -Path ./config.json) -eq $true)
{
    #Import Json Configuration File
    $cnfgSettings =  Get-Content -Raw -Path .\config.json | ConvertFrom-Json;
}
else
{
    #Create Blank Config Object and Export to Json File
    $blnkConfig = new-object PSObject -Property (@{ AD_Parent_Domain="parent.mycollege.edu"; 
                                                    AD_Child_Domain="child.parent.mycollege.edu";
                                                    AD_Child_Domain_Path="DC=child,DC=parent,DC=mycollege,DC=edu";
                                                    AD_Unnested_Groups=@(@{AD_Unnested_GroupName="Unnested Group1";
                                                                           Object_GUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
                                                                           Nested_Groups=@(@{Nested_Grp_Name="Nested Group 1";
                                                                                             Nested_Grp_GUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";},
                                                                                           @{Nested_Grp_Name="Nested Group 2";
                                                                                             Nested_Grp_GUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";})},
                                                                         @{AD_Unnested_GroupName="Unnested Group2";
                                                                           Object_GUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
                                                                           Nested_Groups=@(@{Nested_Grp_Name="Nested Group 1";
                                                                                             Nested_Grp_GUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";},
                                                                                           @{Nested_Grp_Name="Nested Group 2";
                                                                                             Nested_Grp_GUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";})}
                                                                        );
                                                  });

    #Export Json Config File
    $blnkConfig | ConvertTo-Json -Depth 4 | Out-File .\config.json;

    #Exit Script
    exit;
}

# Go Through Each of the Unnested Groups Listed in the Config file
foreach($cfgADGrp in $cnfgSettings.AD_Unnested_Groups)
{
    #Hash Table for Data Source DNs 
    $htDSDNs = @{};

    #Hash Table for Members to Remove from AD Group  
    $htMTRFG = @{};

    #HashTable for Members to Add to AD Group
    $htMTATG = @{};

    #Pull Current AD Group Membership of the Unnested Group 
    $crntGrpMembers = Get-ADGroupMember -Identity $cfgADGrp.Object_GUID -Server $cnfgSettings.AD_Child_Domain;

    #Load Current Members Into Removals HashTable
    foreach($crntGrpMember in $crntGrpMembers)
    {
        #Check for DN
        if([string]::IsNullOrEmpty($crntGrpMember.distinguishedName) -eq $false)
        {
            $htMTRFG.Add($crntGrpMember.distinguishedName,"1");
        }
        
    }
    
    #Load Each Nested Group Members Into Data Source HashTable
    foreach($nstGrp in $cfgADGrp.Nested_Groups)
    {
        #Pull Members of Nested Group in Child Domain
        $nstGrpMbrs = Get-ADGroupMember -Identity $nstGrp.Nested_Grp_GUID -Recursive -Server $cnfgSettings.AD_Child_Domain;

        foreach($nstMbr in $nstGrpMbrs)
        {
            #Check for Nested Members DN Before Putting in Data Source HashTable
            if($htDSDNs.ContainsKey($nstMbr.distinguishedName) -eq $false)
            {
                $htDSDNs.Add($nstMbr.distinguishedName,"1");
            }
            
        }#End of $nstGrpMbrs Foreach
  
    }#End of $cfgADGrp.Nested_Groups Foreach

    #Check Data Source Accounts Before Setting Up Nested Membership Sync
    if($htDSDNs.Count -gt 0)
    {
        #Check Data Source Members
        foreach($dsDN in $htDSDNs.Keys)
        {
            #Don't Remove Existing Members In Data Source Listing
            if($htMTRFG.ContainsKey($dsDN) -eq $true)
            {
                $htMTRFG.Remove($dsDN);
            }
            else 
            {
                #Add Them to List to Be Added to Group
                $htMTATG.Add($dsDN.ToString(),"1");
            }

        }#End of Data Source Members Add or Remove Checks

    }#End of Data Source Accounts Checks

    #Check for Members to Remove
    if($htMTRFG.Count -gt 0)
    {
        foreach($mtrfg in $htMTRFG.Keys)
        {
            #Remove Existing Member. Check for Accounts in Child Domain
            if($mtrfg.ToString().ToLower().Contains($cnfgSettings.AD_Child_Domain_Path.ToLower()) -eq $false)
            {
                Remove-ADGroupMember -Identity $cfgADGrp.Object_GUID -members (Get-ADUser -Identity $mtrfg.ToString() -Server $cnfgSettings.AD_Parent_Domain) -Server $cnfgSettings.AD_Child_Domain -Confirm:$false;
            }
            else
            {
                Remove-ADGroupMember -Identity $cfgADGrp.Object_GUID -members (Get-ADUser -Identity $mtrfg.ToString() -Server $cnfgSettings.AD_Child_Domain) -Server $cnfgSettings.AD_Child_Domain -Confirm:$false;
            }
            
        }#End of $htMTRFG.Keys Foreach

    }#End of Members to Remove

    #Check for Members to Add
    if($htMTATG.Count -gt 0)
    {

        foreach($mtatg in $htMTATG.Keys)
        {
            #Add New Member. Check for Accounts in Child Domain
            if($mtatg.ToString().ToLower().Contains($cnfgSettings.AD_Child_Domain_Path.ToLower()) -eq $false)
            {
                Add-ADGroupMember -Identity $cfgADGrp.Object_GUID -members (Get-ADUser -Identity $mtatg.ToString() -Server $cnfgSettings.AD_Parent_Domain) -Server $cnfgSettings.AD_Child_Domain -Confirm:$false;
            }
            else
            {
                Add-ADGroupMember -Identity $cfgADGrp.Object_GUID -members (Get-ADUser -Identity $mtatg.ToString() -Server $cnfgSettings.AD_Child_Domain) -Server $cnfgSettings.AD_Child_Domain -Confirm:$false;
            }
            
        }#End of $htMTATG.Keys Foreach

    }#End of Members to Add

}#End of $cnfgSettings.AD_Unnested_Groups Foreach