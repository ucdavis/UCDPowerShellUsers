<#
    ps_on_linux.ps1
#>

#Display PS Version
$PSVersionTable

#View Available Commands
Get-Command

#Check Execution Policy
Get-ExecutionPolicy

#What Happens When You Run
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

#Viewing Directory Information
Get-ChildItem 

#Viewing Directory Hidden Info
Get-ChildItem -Hidden

#Viewing Logs
Get-Content -Tail 10 /var/log/forticlient/sslvpn.log

#Pipelines Work 
@("engineering.ucdavis.edu","ece.ucdavis.edu","cs.ucdavis.edu") | Foreach-Object { $pingStatus = Test-Connection $_ -Count 1 -Quiet; "$_ $pingStatus" }

#Creating Object from Linux Command Output
$test = df -h
$test[3]

#What Happens When You Run
$fwStatus = ufw status















