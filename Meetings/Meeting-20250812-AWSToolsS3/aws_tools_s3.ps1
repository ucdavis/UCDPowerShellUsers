<#
    Title: aws_tools_s3.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2025-10-07
#>

#Stopping an Accidental Run
Exit;

#Install AWS Tools Installer Module
Install-Module -Name AWS.Tools.Installer -Scope CurrentUser

#Check to See If Module was Successfully Installed
Get-Module -ListAvailable;

#Install AWS Tools Common Module Using AWS Tools Installer
Install-AWSToolsModule AWS.Tools.Common -CleanUp

#Get AWS PowerShell Version and View More Extensive List of AWS PowerShell Module Names
Get-AWSPowerShellVersion -ListServiceVersionInfo | Format-Table -AutoSize

#Install Various AWS Modules
Install-AWSToolsModule AWS.Tools.S3,AWS.Tools.RDS,AWS.Tools.APIGateway,AWS.Tools.EC2,AWS.Tools.Lambda -CleanUp

#AWS.Tools.APIGateway
#AWS.Tools.EC2
#AWS.Tools.Lambda
#AWS.Tools.RDS
#AWS.Tools.S3

#Update Installed AWS Tools Modules
Update-AWSToolsModule -CleanUp
   
#Get List of AWS Regions
Get-AWSRegion; 

#Setting Default AWS Region for Session
Set-DefaultAWSRegion -Region us-west-2; 

#View Default AWS Region
Get-DefaultAWSRegion;

#Set AWS Credentials
Set-AWSCredential -AccessKey BIGACCESSKEYSTRING -SecretKey VeryLongSecretKey -StoreAs engr-demo

#Get List of AWS Credentials
Get-AWSCredential -ListProfileDetail; 

#View S3 Buckets
Get-S3Bucket -ProfileName engr-viewer;

#Get S3 Bucket Location
Get-S3Bucket -ProfileName engr-viewer | Get-S3BucketLocation -ProfileName engr-viewer

#Get All Items in S3 Bucket
Get-S3Bucket -ProfileName engr-viewer | Get-S3Object -ProfileName engr-viewer

#Get Bucket ACL
Get-S3BucketACL -BucketName "engr-it" -ProfileName engr-viewer

#Upload File to S3 Bucket
Write-S3Object -BucketName "engr-it" -File "C:\COEDevExport\MAE257-Spring2025.mp4" -Key "Videos/MAE257-Week1-Spring2025.mp4" -ProfileName engr-uploader

#Upload Folder to S3 Bucket
Write-S3Object -BucketName "engr-it" -Folder "C:\COEDevExport\PowerShellUsersGroup" -KeyPrefix "PSUGroup" -Recurse -ProfileName engr-uploader
