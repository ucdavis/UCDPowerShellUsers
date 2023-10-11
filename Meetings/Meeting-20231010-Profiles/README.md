## PowerShell Profiles

### Profile file basics

View the Profile variable
```powershell
$PROFILE
```
View current values of the Profile variable
```powershell
$PROFILE | Select-Object *
```
Check for existing Profile file
```powershell
Test-Path $PROFILE
```
Check for Current User All Hosts Profile file
```powershell
Test-Path $PROFILE.AllUsersCurrentHost
```
Create Profile file 
```powershell
New-Item -Path $PROFILE -type file -force
```
Edit Profile file
```powershell
Notepad $PROFILE
```

### Profile file items

Set command line colors
```powershell
Set-PSReadLineOption -Colors @{

  "ContinuationPrompt" = "#F18A00" # UCD Poppy 
  "Emphasis" = "#79242F" # UCD Merlot
  "Error" = "#C10230"  # UCD Double Decker
  "Selection" = "#481268" # UCD Cabernet
  "Default" = "#FFFFFF" # White  
  "Comment" = "#3DAE2B" # UCD Quad
  "Keyword" = "#AADA91" # UCD Farmers Market
  "String" = "#0047BA" # UCD Gunrock
  "Operator" = "#B2B2B2" # UCD Black 30%
  "Variable" = "#6CCA98" # UCD Sage
  "Command" = "#FFBF00" # UCD Gold
  "Parameter" = "#B2B2B2" # UCD Black 30%
  "Type" = "#FFFFFF" # White
  "Number" = "#FFDC00" # UCD Sunflower
  "Member" = "#FFF2CC" # UCD Gold 20%
  #"InlinePrediction" = "#333333" # UCD Black 80%
  #"ListPrediction" = "#FFD24C" # UCD Gold 70%
  #"ListPredictionSelected" = "#7F7F7F" # UCD Black 50%
  
}

```
Set foreground color in console
```powershell
$Host.UI.RawUI.ForegroundColor = "DarkCyan";
```
Set the Window title
```powershell
$host.UI.RawUI.WindowTitle = ("Happy " + (Get-Date).DayOfWeek + "!");
```
Open default browser to UCD Status Page and other helpful sites
```powershell
start-process "https://status.ucdavis.edu";
start-process "https://servicehub.ucdavis.edu";
start-process "https://directory.ucdavis.edu";
#start-process "https://status.office365.com/";
#start-process "https://status.box.com/";
```
Changing the Prompt
```powershell
function prompt { "Wands at the ready coders!`n > "}
```
Changing Prompt to the Computer Name and Current Directory Path
```powershell
function prompt{
  "PS [$env:computername] $(Get-Location)>";
}
```
Get AD Computers Function
```powershell
function get-ucd-servers{

  #Custom Reporting Object for Server Listing
  $cstSrvRpt = new-object PSObject -Property (@{UCDServers=@(); Status=""});
  $cstSrvRpt.Status = "";

  #Array of Server OU DNs
  $ServerOUs = $("OU=unit1,OU=MyUnits,OU=MyDepartment,DC=my,DC=college,DC=edu",
                 "OU=unit2,OU=MyUnits,OU=MyDepartment,DC=my,DC=college,DC=edu",
                 "OU=unit4,OU=MyUnits,OU=MyDepartment,DC=my,DC=college,DC=edu",
                 "OU=unit6,OU=MyUnits,OU=MyDepartment,DC=my,DC=college,DC=edu",
                 "OU=unit8,OU=MyUnits,OU=MyDepartment,DC=my,DC=college,DC=edu");

  #Check Connection to Campus
  if((Test-Connection -Ping -TargetName my.college.edu -Count 1 -TimeoutSeconds 1).Status -eq "Success")
  {
      #Import the Active Directory Module
      Import-Module ActiveDirectory;

      #Loop Through OUs and Get All AD Computers (Including the IPv4Address) and Add Them to Reporting Array
      Foreach($srvrOU in $ServerOUs)
      {
          $cstSrvRpt.UCDServers += Get-ADComputer -Filter 'Enabled -eq $True' -SearchBase $srvrOU -SearchScope Subtree -Server my.college.edu -Properties IPv4Address | Select-Object -Property Name,DNSHostName,IPv4Address;
      }
  
  }
  else 
  {
      #Display Status of Failed Ping
      $cstSrvRpt.Status = "Couldn't ping domain. Check your Campus connection!";
      return $cstSrvRpt.Status;
  }

  #Display Server Report Array
  return $cstSrvRpt.UCDServers;

}#End of get-ucd-servers

```
Pinging a group of systems
```powershell
@("dc12c.my.college.edu","dc14c.my.college.edu","dc15c.my.college.edu") | Foreach-Object { $pingStatus = Test-Connection $_ -Count 1 -Quiet; "$_ $pingStatus" }
```
Change Location to the Desktop
```powershell
Set-Location ([Environment]::GetFolderPath("Desktop").ToString());
```

### Checking Profile Settings

View command line colors
```powershell
Get-PSReadLineOption
```
View the current Prompt code block
```powershell
(Get-Command Prompt).ScriptBlock
```
View host UI settings
```powershell
$host.UI.RawUI
```





