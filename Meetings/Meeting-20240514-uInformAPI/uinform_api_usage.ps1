<#
    Title: uinform_api_usage.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-05-15
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
    $url = $uInformAPIInfo.url_base + "ManagedGroups";

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

#Function for Getting AD3 Managed Group by Name
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

#Function for Getting AD3 Managed Group by Guid
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

#Function for Removing AD3 Managed Group
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

#Function for Getting Membership of AD3 Managed Group
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

#Function for Submitting an AD3 Managed Group Membership Change
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

#Stopping an Accidental Run
exit;

#Pull User Information
Get-uInformAPIAD3UserByUserID -UserID "dbunn";

#Create a New AD3 Managed Group
Add-uInformAPIAD3ManagedGroup -GroupName "COE-JollyDevs" -GroupDisplayName "COE Jolly Devs" -GroupDiscription "The Jolly Developers of COE" -GroupMaxMembers 0;

#Pull AD3 Managed Group by Name
Get-uInformAPIAD3ManagedGroupByName -GroupName "COE-JollyDevs";

#Submit AD3 Managed Group Membership Change
Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID "060adaf5-9f07-4604-8988-f3cbfdd05da0" -MembershipAction "ADD" -MemberGUID "0a0a2344-613a-4b69-8778-8f5fb3427ef6";

#Pull AD3 Managed Group by GUID
Get-uInformAPIAD3ManagedGroupByGUID -GroupGUID "f3b2434f-34b6-4f24-874e-9365eff3133d";

#Pull AD3 Managed Group Memembership
Get-uInformAPIAD3ManagedGroupMembership -GroupGUID "40147a00-fe74-446a-b8b7-ca4ad5047939";

#Remove AD3 Managed Group by GUID 
Remove-uInformAPIAD3ManagedGroup -GroupGUID "f3b2434f-34b6-4f24-874e-9365eff3133d";

#Array of User Guids
$arrUserGuids = @("ee07f20f-2c44-47cd-a2ce-aa8444da60ed",
                  "0a0a2344-613a-4b69-8778-8f5fb3427ef6",
                  "2db36974-a202-449e-bda7-b7bf59703398",
                  "96951b24-9cc8-41fe-9b94-a6d312b34735",
                  "0d20c3f7-6b9a-4c0d-ad0d-9b5aa879a9df",
                  "413a516b-a59e-4bb0-ab59-d7b3f3642041");

#Add Users to Group
foreach($ucdUsrGuid in $arrUserGuids)
{
    Submit-uInformAPIAD3ManagedGroupMembershipChange -GroupGUID "40147a00-fe74-446a-b8b7-ca4ad5047939" -MembershipAction "ADD" -MemberGUID $ucdUsrGuid;
}


<#
objectGuid                 : 40147a00-fe74-446a-b8b7-ca4ad5047939
displayName                : COE Jolly Devs
distinguishedName          : CN=COE-JollyDevs,OU=UserCreatedGroups,OU=ManagedGroups,DC=ad3,DC=ucdavis,DC=edu
ownedByGuid                : a10b04ae-cfaa-43b2-b096-dcf2e9430564
managedByGuid              : 060adaf5-9f07-4604-8988-f3cbfdd05da0
hasScopeOver               :
maxMembers                 : 0
extensionAttribute6        :
samAccountName             : COE-JollyDevs
description                : The Jolly Developers of COE
msExchRecipientDisplayType :
proxyAddresses             : {}
gidNumber                  : 247960485
#>

