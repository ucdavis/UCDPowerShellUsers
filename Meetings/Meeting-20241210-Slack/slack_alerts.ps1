<#
    Title: slack_alerts.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-12-10
#>

#Custom Object for Slack API Information
$global:SlackAPIInfo = new-object PSObject -Property (@{ webhook_base=""; dev_channel_path=""; prod_channel_path="";});

#Pull Slack API Information for Password Vault
$SlackAPIInfo.webhook_base = Get-Secret -Name "Slack-Webhook-Base" -AsPlainText -Vault UCDAccounts;
$SlackAPIInfo.dev_channel_path = Get-Secret -Name "Slack-Webhook-Dev" -AsPlainText -Vault UCDAccounts;

#Quick Check to Make Sure Webhook Values Pulled From Vault
if([string]::IsNullOrEmpty($SlackAPIInfo.webhook_base) -eq $false -and [string]::IsNullOrEmpty($SlackAPIInfo.dev_channel_path) -eq $false)
{
    #Var for Dev Channel URI 
    $uriDevChannel = $SlackAPIInfo.webhook_base + $SlackAPIInfo.dev_channel_path;

    #Custom Object for Slack API Message Body
    $cstPostBody = New-Object PSObject -Property (@{text="";});

    #Set Message Text
    $cstPostBody.text = "Whooty whooo";

    #Convert Post Body to Json Object
    $jsonPostBody = $cstPostBody | ConvertTo-Json -Compress;

    #Make API call to AWS
    $slackAPICallStatus = Invoke-RestMethod -Uri $uriDevChannel -Method Post -Body $jsonPostBody -ContentType "application/json" -TimeoutSec 240;

    $slackAPICallStatus;

}#End of SlackAPIInfo Null\Empty Checks
