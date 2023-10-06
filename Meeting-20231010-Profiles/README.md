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

Set Command Line Colors
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
  "InlinePrediction" = "#333333" # UCD Black 80%
  "ListPrediction" = "#FFD24C" # UCD Gold 70%
  "ListPredictionSelected" = "#7F7F7F" # UCD Black 50%
  
}
```





