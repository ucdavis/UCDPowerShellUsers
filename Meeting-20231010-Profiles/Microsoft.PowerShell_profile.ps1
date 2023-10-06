<#
  PowerShell Profile
#>

#Set Command Colors
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

# Set Foreground Color in Console
$Host.UI.RawUI.ForegroundColor = "DarkCyan";

#Open Browser to UCD Status Page and Other Helpful Sites
start-process "https://status.ucdavis.edu";
start-process "https://servicehub.ucdavis.edu";
start-process "https://directory.ucdavis.edu";
#start-process "https://status.office365.com/";
#start-process "https://status.box.com/";

# Set the Window Title
$host.UI.RawUI.WindowTitle = ("Happy " + (Get-Date).DayOfWeek + "!");

# Changing the Prompt
function prompt { "Wands at the ready coders!`n > "}

# Changing the Prompt to Display User and System Names
function prompt {"$env:USERDOMAIN\$env:USERNAME on $($env:COMPUTERNAME.ToString().ToLower())`n> "}

# Pinging a Group Of Systems 
@("addc12c.ad3.ucdavis.edu","addc14c.ad3.ucdavis.edu","addc15c.ad3.ucdavis.edu") | Foreach-Object { $pingStatus = Test-Connection $_ -Count 1 -Quiet; "$_ $pingStatus" }

