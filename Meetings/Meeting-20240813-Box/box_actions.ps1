<#
    Title: box_actions.ps1
    Authors: Dean Bunn, Ben Clark, and Calvin Robertson
    Last Edit: 2024-08-12
#>

#Custom Object for Box Token Information
$global:BoxAPITokenInfo = new-object PSObject -Property (@{ box_api_token=""; expires_in_ticks=0;});

function Get-BoxAPIToken()
{

    #Check to See if a New Token Needs to Requested
    if([Int64](Get-Date).AddMinutes(15).Ticks -gt $BoxAPITokenInfo.expires_in_ticks)
    {

        #Var for Base Box OAuth URL
        [string]$box_oauth2_url = "https://api.box.com/oauth2/token";

        #Custom Dictionary for Box Required Items
        $boxRequest = @{client_id = "";
                        client_secret = "";
                        grant_type = "client_credentials";
                        box_subject_type = "enterprise";
                        box_subject_id = "252054";};

        #Load Secrets for API Call
        $boxRequest.client_id = Get-Secret -Name "Box-ClientID" -AsPlainText -Vault UCDInfo;
        $boxRequest.client_secret = Get-Secret -Name "Box-ClientSecret" -AsPlainText -Vault UCDInfo;

        #Var for Headers Used in API Call 
        $headers = @{"Content-Type"="application/x-www-form-urlencoded"};

        #API Call to Box OAuth2 URL
        $rtnTokenInfo = Invoke-RestMethod -Uri $box_oauth2_url -Method Post -Headers $headers -Body $boxRequest;

        #Null\Empty Check on Returned API Token
        if([string]::IsNullOrEmpty($rtnTokenInfo.access_token) -eq $false)
        {
            $BoxAPITokenInfo.box_api_token = $rtnTokenInfo.access_token;
            $BoxAPITokenInfo.expires_in_ticks = (Get-Date).AddSeconds($rtnTokenInfo.expires_in).Ticks;
        }
        else 
        {

            #Stop the Script Due to API Token Not Being Returned
            Write-Output "Script stopped due to no API token returned";
            exit;

        }#End of Access Token Null\Empty Checks

    }#End of Expires Checks
   
}#End of Get-BoxAPIToken Function


#Pull OAuth API Access Token from Box
Get-BoxAPIToken;

#Var for Header Authorization Bearer Key to Box
$headersBox = @{"Authorization"="Bearer " + $BoxAPITokenInfo.box_api_token};

#Var for Box API Base URL
[string]$boxAPIBaseURL = "https://api.box.com/2.0/";

#Var for URL of Box "Me" User
[string]$boxMeURL = "https://api.box.com/2.0/users/me";

#Var for URL of Home Folder
[string]$boxHFURL = "https://api.box.com/2.0/folders/0";

#Pull Account Associated with OAuth Token
Invoke-RestMethod -Uri $boxMeURL -Method Get -Headers $headersBox;

#Pull Home Folder for Account
Invoke-RestMethod -Uri $boxHFURL -Method Get -Headers $headersBox;
#>

#Array of Box Testing Folders
$arrBoxTestingFolders = @();

#Custom Objects for Box Testing Folders
$boxFldrDLPData = new-object PSObject -Property (@{ box_folder_name="COE-DLP-Testing-Data1"; box_folder_id="278656463669";});
$boxFldrDLPResearch = new-object PSObject -Property (@{ box_folder_name="COE-DLP-Testing-Research1"; box_folder_id="278655100161";});
$boxFldrDLPShares = new-object PSObject -Property (@{ box_folder_name="COE-DLP-Testing-Shares1"; box_folder_id="278656708709";});

#Adding Testing Folders to Array
$arrBoxTestingFolders += $boxFldrDLPData;
$arrBoxTestingFolders += $boxFldrDLPResearch;
$arrBoxTestingFolders += $boxFldrDLPShares;

#Loop Through Box Testing Folders
foreach($boxTF in $arrBoxTestingFolders)
{

    #Var for URI Box Folder Basic Information
    [string]$boxURIFldrInfo = $boxAPIBaseURL + "folders/" + $boxTF.box_folder_id;

    #Var for URI Box Folder Items
    [string]$boxURIFldrItems = $boxURIFldrInfo + "/items?fields=size,name,tags,file_version,created_at,modified_at,modified_by";

    #Var for URI Box Folder Collaborators
    [string]$boxURIFldrCollabs = $boxURIFldrInfo + "/collaborations";

    #Var for URI Box Upload Files
    [string]$boxURIUploadFiles = "https://upload.box.com/api/2.0/files/content";

    #Pull Basic Folder Information
    if($boxTF.box_folder_name -eq "COE-DLP-Testing-Data")
    {
       #Getting Folder Basic Information
       Invoke-RestMethod -Uri $boxURIFldrInfo -Method Get -Headers $headersBox;

       #Getting a Folder Items
       (Invoke-RestMethod -Uri $boxURIFldrItems -Method Get -Headers $headersBox).entries;

    }

    #Pull Folder Collaborators
    if($boxTF.box_folder_name -eq "COE-DLP-Testing-Shares")
    {
        #Getting Collaborators Listed on Folder
        (Invoke-RestMethod -Uri $boxURIFldrCollabs -Method Get -Headers $headersBox).entries;
    }

    #Upload Files to a Folder
    if($boxTF.box_folder_name -eq "COE-DLP-Testing-Research")
    {

        #Var for Local File to Upload to Box
        $localFile = "C:\Users\dbunn\Downloads\CR1000-Homewood-LakeData.txt";

        #Read the Content of the File
        $fileContent = [System.IO.File]::ReadAllBytes($localFile);

        #Create the Form Data for the Request
        $boundary = [System.Guid]::NewGuid().ToString();
        $contentType = "multipart/form-data; boundary=`"$boundary`""

        $attributesPart = "--$boundary`r`n" +
                            "Content-Disposition: form-data; name=`"attributes`"`r`n`r`n" +
                            "{`"name`":`"$(Split-Path -Leaf $localFile)`",`"parent`":{`"id`":`"" + $boxTF.box_folder_id + "`"}}`r`n"

        $filePart = "--$boundary`r`n" +
                        "Content-Disposition: form-data; name=`"file`"; filename=`"$(Split-Path -Leaf $localFile)`"`r`n" +
                        "Content-Type: application/octet-stream`r`n`r`n" +
                        [System.Text.Encoding]::UTF8.GetString($fileContent) + "`r`n" +
                        "--$boundary--`r`n"

        $body = $attributesPart + $filePart

        #Upload File to Box
        Invoke-RestMethod -Uri $boxURIUploadFiles -Headers $headersBox -Method Post -Body $body -ContentType $contentType

    }


}#End of $arrBoxTestingFolders Foreach

#>