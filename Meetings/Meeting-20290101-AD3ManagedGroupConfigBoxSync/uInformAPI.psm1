
#Function for Retreiving an AD3 Managed Group General Information
function Get-uInformAPIAD3ManagedGroupGeneralInfo()
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
    $sig = $method + ":" + $timestamp + ":" + $UCDAPIInfo.uinform_public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($UCDAPIInfo.uinform_private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $UCDAPIInfo.uinform_url_base + "ManagedGroups/" + $GroupGUID

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($UCDAPIInfo.uinform_public_key, $p)

    #Make API request, selecting JSON properties from response
    $rspObj = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing -ContentType "application/json" | ConvertFrom-Json

    return $rspObj.responseObject;

}

#Function for Submitting an AD3 Managed Group Config Box Sync Change
function Submit-uInformAPIAD3ManagedGroupConfigBoxSync()
{
    Param
    (
         [Parameter(Mandatory=$true)]
         [string] $GroupGUID,
         [Parameter(Mandatory=$true)]
         [string] $GrpExtensionAttr6,
         [Parameter(Mandatory=$true)]
         [string] $GrpDisplayName,
         [Parameter(Mandatory=$true)]
         [string] $GrpDescription,
         [Parameter(Mandatory=$true)]
         [AllowNull()]
         [Nullable[System.Int32]]
         $GrpMaxMbr
    )

    #Custom Object for Put Body
    $cstPutBody = new-object PSObject -Property(@{ displayName=""; description=""; maxMembers=$null; extensionAttribute6="";});
    $cstPutBody.extensionAttribute6 = $GrpExtensionAttr6
    $cstPutBody.displayName = $GrpDisplayName
    $cstPutBody.description = $GrpDescription

    #Quick Check for Null or Empty Max Number
    if($null -ne $GrpMaxMbr -and $GrpMaxMbr -ne 0)
    {
        $cstPutBody.maxMembers = $GrpMaxMbr;
    }
    else 
    {
        $cstPutBody.maxMembers = $null;
    }
    
    #Convert Post Body to Json Object
    $jsonPutBody = $cstPutBody | ConvertTo-Json -Compress;

    #Var for Http Method
    $method = "PUT"

    #Configure Request Signature
    $timestamp =[int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
    $sig = $method + ":" + $timestamp + ":" + $UCDAPIInfo.uinform_public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($UCDAPIInfo.uinform_private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $UCDAPIInfo.uinform_url_base + "ManagedGroups/" + $GroupGUID

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($UCDAPIInfo.uinform_public_key, $p)

    #Make API request, selecting JSON properties from response
    $rspObj = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing -Body $jsonPutBody -ContentType "application/json" | ConvertFrom-Json

    return $rspObj.responseObject;

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
    $sig = $method + ":" + $timestamp + ":" + $UCDAPIInfo.uinform_public_key;
    $sha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1");
    $sha.Key = [System.Text.Encoding]::UTF8.Getbytes($UCDAPIInfo.uinform_private_key);
    $enc = [Convert]::Tobase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.Getbytes($sig)));

    #Configure URL
    $url = $UCDAPIInfo.uinform_url_base + "ManagedGroups/" + $GroupGUID + "/members"

    #Configure Headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $headers.Add('Accept','Application/Json')
    $headers.Add('X-UTIMESTAMP', $timestamp)

    #Create a Credential Object for HTTP Basic Auth
    $p = $enc | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($UCDAPIInfo.uinform_public_key, $p)

    #Make API request, selecting JSON properties from response
    $rspObj = Invoke-WebRequest $url -Method $method -Headers $headers -Credential $credential -UseBasicParsing -Body $jsonPostBody -ContentType "application/json" | ConvertFrom-Json;

    return $rspObj.responseObject;
}
