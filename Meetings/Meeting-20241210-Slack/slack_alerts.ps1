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
$SlackAPIInfo.prod_channel_path = Get-Secret -Name "Slack-Webhook-Prod" -AsPlainText -Vault UCDAccounts;

#Quick Check to Make Sure Webhook Values Pulled From Vault
if([string]::IsNullOrEmpty($SlackAPIInfo.webhook_base) -eq $false -and [string]::IsNullOrEmpty($SlackAPIInfo.dev_channel_path) -eq $false)
{

    #Var for Dev Channel URI 
    #$uriDevChannel = $SlackAPIInfo.webhook_base + $SlackAPIInfo.dev_channel_path;

    #Var for Prod Channel URI
    $uriProdChannel = $SlackAPIInfo.webhook_base + $SlackAPIInfo.prod_channel_path;
    
    #Custom Object for Basic Slack API Message Body
    $cstPostBodyBasic = New-Object PSObject -Property (@{text="";});

    #Set Message Text
    $cstPostBodyBasic.text = "Howdy, World";

    #Convert Basic Post Body Object to Json
    $jsonPostBodyBasic = $cstPostBodyBasic | ConvertTo-Json -Compress;

    #Make API call to Slack
    $slackAPIBasicCallStatus = Invoke-RestMethod -Uri $uriProdChannel -Method Post -Body $jsonPostBodyBasic -ContentType "application/json";

    #Should Return "OK"
    $slackAPIBasicCallStatus;
    #>

    <#
    #Array of Server Names to Ping Check
    $arrServers = @("addc12c","coe-it-data","coe-it-abx22","coe-it-sql22","coe-it-wvs22","coe-it-app22","coe-it-wins22");

    #Var for Json Post Servers 
    [string]$jsonPostServers = "{""blocks"": [{""type"": ""header"",""text"": {""type"": ""plain_text"",""text"": ""Server Availability Status"",""emoji"": true}},{""type"": ""section"",""text"": {""type"": ""mrkdwn"",""text"": """;

    #Var for Server Ping Status Json
    [string]$jsonSrvStatus = "The following systems were pinged at " + (Get-Date).ToShortTimeString() + "\n\n";

    foreach($uServer in $arrServers)
    {

       #Var for Ping Count
       [int32]$pingCntChecks = 1;

       #Var for Max Ping Failure
       [int32]$pingMaxFails = 1;

       #Var for Ping Fails 
       [int32]$pingFails = 0;

       #Ping Server Four Times and Check Results
       $pingResults = Test-Connection -TargetName $uServer -Count $pingCntChecks;

       foreach($pingResult in $pingResults)
       {

           if($pingResult.Status.ToString().ToLower() -ne "success")
           {
                $pingFails++;
           }

       }

       if($pingFails -ge $pingMaxFails)
       {
         #Add Failed Server Status Block to Json Server Status. ":skull:" and ":scream:" are options for emoji
         $jsonSrvStatus += ":ghost: " + $uServer + "\n"; 

       }
       else 
       {
         #Add Happy Server Status Block to Json Server Status
         $jsonSrvStatus += ":gunrock: " + $uServer + "\n";
       }
     
    }

    #Add Json Server Status to Main Post Server Message Body
    $jsonPostServers += $jsonSrvStatus;
    $jsonPostServers += """}}]}";

    #Make API call to Slack
    $slackAPIAdvCallStatus = Invoke-RestMethod -Uri $uriProdChannel -Method Post -Body $jsonPostServers -ContentType "application/json";

    #Should Return "OK"
    $slackAPIAdvCallStatus;
    #>

}#End of SlackAPIInfo Null\Empty Checks
