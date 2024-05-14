<#
    Title: uinform_api_usage.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-05-14
#>

#Custom Object for uInform API Information
$global:uInformAPIInfo = new-object PSObject -Property (@{ public_key=""; private_key=""; url_base="";});

#Load Public and Private Keys for uInform API Access
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

    #Configure Request Signature
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

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($uInformAPIInfo.public_key, $p)

    #Make API request, selecting JSON properties from response
    $user = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing | ConvertFrom-Json;

    return $user.responseObject;
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

    #Var for Http Method
    $method = "POST"

    #Configure Request Signature
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

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($uInformAPIInfo.public_key, $p)

    #Make API request, selecting JSON properties from response
    $rspObj = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing -Body $jsonPostBody -ContentType "application/json" | ConvertFrom-Json;

    return $rspObj.responseObject;
}

function Get-uInformAPIAD3ManagedGroupByName()
{
    Param
    (
         [Parameter(Mandatory=$true)]
         [string] $GroupName
    )

    #Var for Http Method
    $method = "GET"

    #Configure Request Signature
    $timestamp =[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
    $sig = $method + ":" + $timestamp + ":" + $uInformAPIInfo.public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($uInformAPIInfo.private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $uInformAPIInfo.url_base + "ManagedGroups/sam/" + $GroupName;

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($uInformAPIInfo.public_key, $p)

    #Make API request, selecting JSON properties from response
    $groupInfo = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing | ConvertFrom-Json;

    return $groupInfo.responseObject;

}

function Get-uInformAPIAD3ManagedGroupByGUID()
{
    Param
    (
         [Parameter(Mandatory=$true)]
         [string] $GroupGUID
    )

    #Var for Http Method
    $method = "GET"

    #Configure Request Signature
    $timestamp =[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
    $sig = $method + ":" + $timestamp + ":" + $uInformAPIInfo.public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($uInformAPIInfo.private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $uInformAPIInfo.url_base + "ManagedGroups/guid/" + $GroupGUID;

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($uInformAPIInfo.public_key, $p)

    #Make API request, selecting JSON properties from response
    $groupInfo = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing | ConvertFrom-Json;

    return $groupInfo.responseObject;

}

function Remove-uInformAPIAD3ManagedGroup()
{
    Param
    (
         [Parameter(Mandatory=$true)]
         [string] $GroupGUID
    )

    #Var for Http Method
    $method = "DELETE"

    #Configure Request Signature
    $timestamp =[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
    $sig = $method + ":" + $timestamp + ":" + $uInformAPIInfo.public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($uInformAPIInfo.private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $uInformAPIInfo.url_base + "ManagedGroups/" + $GroupGUID;

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($uInformAPIInfo.public_key, $p)

    #Make API request, selecting JSON properties from response
    $rmvRqst = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing | ConvertFrom-Json;

    return $rmvRqst.responseObject;
}
function Get-uInformAPIAD3ManagedGroupMembership()
{
    Param
    (
         [Parameter(Mandatory=$true)]
         [string] $GroupGUID
    )

    #Var for Http Method
    $method = "GET"

    #Configure Request Signature
    $timestamp =[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
    $sig = $method + ":" + $timestamp + ":" + $uInformAPIInfo.public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($uInformAPIInfo.private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $uInformAPIInfo.url_base + "ManagedGroups/" + $GroupGUID + "/members";

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($uInformAPIInfo.public_key, $p)

    #Make API request, selecting JSON properties from response
    $groupMbrs = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing | ConvertFrom-Json;

    return $groupMbrs.responseObject;

}

function Submit-uInformAPIAD3ManagedGroupMembershipChange()
{
    Param
    (
         [Parameter(Mandatory=$true)]
         [string] $GroupGUID,
         [Parameter(Mandatory=$true)]
         [string] $MembershipAction,
         [Parameter(Mandatory=$true)]
         [string] $MemberGUID
    )

    #Custom Object for Post Body
    $cstPostBody = new-object PSObject -Property(@{ userGuid=""; action="";});
    $cstPostBody.userGuid = $MemberGUID
    $cstPostBody.action = $MembershipAction.ToString().ToUpper();

    #Convert Post Body to Json Object
    $jsonPostBody = $cstPostBody | ConvertTo-Json -Compress;

    #Var for Http Method
    $method = "POST"

    #Configure Request Signature
    $timestamp =[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
    $sig = $method + ":" + $timestamp + ":" + $uInformAPIInfo.public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($uInformAPIInfo.private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $uInformAPIInfo.url_base + "ManagedGroups/" + $GroupGUID + "/members"

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($uInformAPIInfo.public_key, $p)

    #Make API request, selecting JSON properties from response
    $rspObj = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing -Body $jsonPostBody -ContentType "application/json" | ConvertFrom-Json;

    return $rspObj.responseObject;
}

#Pull User Information
Get-uInformAPIAD3UserByUserID -UserID "dbunn";

#Create a New AD3 Managed Group
#Add-uInformAPIAD3ManagedGroup -GroupName "COE-JollyDevs" -GroupDisplayName "COE Jolly Devs" -GroupDiscription "The Jolly Developers of COE" -GroupMaxMembers 0;

#Pull AD3 Managed Group by Name
#Get-uInformAPIAD3ManagedGroupByName -GroupName "COE-SunnyDevs";

#Submit AD3 Managed Group Membership Change
#Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID "f3b2434f-34b6-4f24-874e-9365eff3133d" -MembershipAction "REMOVE" -MemberGUID "0a0a2344-613a-4b69-8778-8f5fb3427ef6";

#Pull AD3 Managed Group by GUID
#Get-uInformAPIAD3ManagedGroupByGUID -GroupGUID "f3b2434f-34b6-4f24-874e-9365eff3133d";

#Pull AD3 Managed Group Memembership
#Get-uInformAPIAD3ManagedGroupMembership -GroupGUID "f3b2434f-34b6-4f24-874e-9365eff3133d";

##Remove AD3 Managed Group by GUID 
##Remove-uInformAPIAD3ManagedGroup -GroupGUID "b14fecaf-dec2-48e8-8d9e-b718b9a9f423";

<#
$arrUserGuids = @("ee07f20f-2c44-47cd-a2ce-aa8444da60ed",
                  "0a0a2344-613a-4b69-8778-8f5fb3427ef6",
                  "2db36974-a202-449e-bda7-b7bf59703398",
                  "96951b24-9cc8-41fe-9b94-a6d312b34735",
                  "0d20c3f7-6b9a-4c0d-ad0d-9b5aa879a9df",
                  "413a516b-a59e-4bb0-ab59-d7b3f3642041");

foreach($ucdUsrGuid in $arrUserGuids)
{
    Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID "f3b2434f-34b6-4f24-874e-9365eff3133d" -MembershipAction "ADD" -MemberGUID $ucdUsrGuid;
}
#>

#Demo AD3 Users
#BC objectGuid: ee07f20f-2c44-47cd-a2ce-aa8444da60ed
#DB objectGuid: 0a0a2344-613a-4b69-8778-8f5fb3427ef6
#CD objectGuid: 2db36974-a202-449e-bda7-b7bf59703398
#SC objectGuid: 96951b24-9cc8-41fe-9b94-a6d312b34735
#RC objectGuid: 0d20c3f7-6b9a-4c0d-ad0d-9b5aa879a9df
#TM objectGuid: 413a516b-a59e-4bb0-ab59-d7b3f3642041
#Demo AD3 Groups
#CA objectGuid: ad4ca617-85f5-4514-a61f-f0f9dd9f8b90


<#
objectGuid                 : f3b2434f-34b6-4f24-874e-9365eff3133d
displayName                : COE-SunnyDevs
distinguishedName          : CN=COE-SunnyDevs,OU=UserCreatedGroups,OU=ManagedGroups,DC=ad3,DC=ucdavis,DC=edu
ownedByGuid                : bd7bd795-a1ba-4bf7-baa1-0b09498f1c92
managedByGuid              : f3c79add-eae9-4112-873a-0708984a5c96
hasScopeOver               :
maxMembers                 : 0
extensionAttribute6        :
samAccountName             : COE-SunnyDevs
description                : COE Sunny Developers
msExchRecipientDisplayType :
proxyAddresses             : {}
gidNumber                  : 296878848
#>