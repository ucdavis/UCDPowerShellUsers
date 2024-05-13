<#
    Title: uinform_api_usage.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-05-14
#>

#Custom Object for uInform API Information
$global:uInformAPIInfo = new-object PSObject -Property (@{ public_key=""; private_key=""; url_base="";});

#Load Public and Private Keys for uInform API Access. Run Something Like Get-SecretInfo -Name * to Unlock Vault for Non-Automated Work
$uInformAPIInfo.public_key = Get-Secret -Name "uInformAPI-Pubkey" -AsPlainText -Vault UCDAccounts
$uInformAPIInfo.private_key = Get-Secret -Name "uInformAPI-Pvtkey" -AsPlainText -Vault UCDAccounts
$uInformAPIInfo.url_base = "https://ws.uinform.ucdavis.edu/";

#Function for Retrieving an AD3 User by User ID
function Get-uInformAPIAD3UserByUserID()
{
    Param
    (
         [Parameter(Mandatory=$true)]
         [string] $UserID
    )

    #Var for Http Method
    $method = "GET"

    $timestamp =[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
    $sig = $method + ":" + $timestamp + ":" + $uInformAPIInfo.public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($uInformAPIInfo.private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $uInformAPIInfo.url_base + "adusers/sam/" + $UserID;

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a credential object for HTTP basic auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($uInformAPIInfo.public_key, $p)

    #Make API request, selecting JSON properties from response
    $user = (Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing | ConvertFrom-Json).responseObject;

    return $user;
}

#Function for Creating AD3 Managed Group
function Add-uInformAPIAD3ManagedGroup()
{

    Param
    (
         [Parameter(Mandatory=$true)]
         [string] $GroupName,
         [Parameter(Mandatory=$true)]
         [string] $GroupDisplayName,
         [Parameter(Mandatory=$true)]
         [string] $GroupDiscription,
         [Parameter(Mandatory=$true)]
         [int] $GroupMaxMembers
    )

    #Custom Object for Post Body
    $cstPostBody = new-object PSObject -Property(@{ groupName=""; displayName=""; description=""; maxMembers=0;});
    $cstPostBody.groupName = $GroupName;
    $cstPostBody.displayName = $GroupDisplayName;
    $cstPostBody.description = $GroupDiscription;
    $cstPostBody.maxMembers = $GroupMaxMembers;

    #Convert Post Body to Json Object
    $jsonPostBody = $cstPostBody | ConvertTo-Json -Compress;

    $jsonPostBody;

    #Var for Http Method
    $method = "POST"

    $timestamp =[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
    $sig = $method + ":" + $timestamp + ":" + $uInformAPIInfo.public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($uInformAPIInfo.private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $uInformAPIInfo.url_base + "ManagedGroups" + $userID;

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a credential object for HTTP basic auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($uInformAPIInfo.public_key, $p)

    #Make API request, selecting JSON properties from response
    $rspObj = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing -Body $jsonPostBody -ContentType "application/json" | ConvertFrom-Json;

    return $rspObj;
}

#Pull User Information for Big Ben
Get-uInformAPIAD3UserByUserID -UserID "benclark";


<#
#Create a New AD3 Managed Group
$newGrpResponse = Add-uInformAPIAD3ManagedGroup -GroupName "COE-SunnyDevs" -GroupDisplayName "COE-SunnyDevs" -GroupDiscription "COE Sunny Developers" -GroupMaxMembers 0;

#View Success
$newGrpResponse.success;

#View Response Object
$newGrpResponse.responseObject;
#>

<#
True
requestGuid            : cad8658a-4f2d-4781-8287-77a1524006c5
requestId              : 197944
name                   : create-managed-group
statusId               : 0
status                 :
payload                :
submittedBy            : ADMIN-DBUNN@AD3.UCDAVIS.EDU
submitterGuid          : ADMIN-DBUNN@AD3.UCDAVIS.EDU
submittedDateTimeUtc   : 5/13/2024 4:00:09 AM
scheduledDateTimeUtc   : 5/13/2024 4:00:09 AM
lastUpdatedDateTimeUtc : 5/13/2024 4:00:09 AM
#>


