<#
    Title: box_work.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-08-02
#>

#Var for Base Box URL
[string]$box_oauth2_url = "https://api.box.com/oauth2/token";

#Custom Dictionary for Required Canvas Enrollment Post
$boxRequest = @{client_id = "xxxxx";
                client_secret = "xxxxx";
                grant_type = "client_credentials";
                box_subject_type = "enterprise";
                box_subject_id = "252054";};

#Var for Headers Used in API Call 
$headers = @{"Content-Type"="application/x-www-form-urlencoded"};

#API Call to Box OAuth2 URL
$rtnTokenInfo = Invoke-RestMethod -Uri $box_oauth2_url -Method Post -Headers $headers -Body $boxRequest;

#View Returned Token Information
$rtnTokenInfo;

<#
https://developer.box.com/reference/get-folders-id-items/

AutomationUser_2272535_9e1vFdXNPh@boxdevedition.com


#>