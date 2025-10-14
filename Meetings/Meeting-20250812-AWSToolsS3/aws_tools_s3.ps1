<#
    Title: aws_tools_s3.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2025-10-14
#>

#Stopping an Accidental Run
Exit;

#Install AWS Tools Installer Module
Install-Module -Name AWS.Tools.Installer -Scope CurrentUser

#Check to See If Module was Successfully Installed
Get-InstalledModule

#View Full List of Available Modules
Get-Module -ListAvailable;

#Install AWS Tools Common Module Using AWS Tools Installer
Install-AWSToolsModule AWS.Tools.Common -CleanUp

#Get AWS PowerShell Version and View More Extensive List of AWS PowerShell Module Names
Get-AWSPowerShellVersion -ListServiceVersionInfo | Format-Table -AutoSize

#Install Various AWS Modules
Install-AWSToolsModule AWS.Tools.S3,AWS.Tools.RDS,AWS.Tools.EC2,AWS.Tools.Lambda,AWS.Tools.APIGateway,AWS.Tools.Glacier -CleanUp

# AWS.Tools.APIGateway
# AWS.Tools.EC2
# AWS.Tools.Glacier
# AWS.Tools.Lambda
# AWS.Tools.RDS
# AWS.Tools.S3

#Update Installed AWS Tools Modules
Update-AWSToolsModule -CleanUp

#View Commands Listed in a Module
Get-Command -Module AWS.Tools.Common
   
#Get List of AWS Regions
Get-AWSRegion; 

#Setting Default AWS Region for Session
Set-DefaultAWSRegion -Region us-west-2; 

#View Default AWS Region
Get-DefaultAWSRegion;

#Set AWS Credentials
Set-AWSCredential -AccessKey BIGACCESSKEYSTRING -SecretKey VeryLongSecretKey -StoreAs engr-psdemo

#Get List of AWS Credentials
Get-AWSCredential -ListProfileDetail; 

##############################
# S3
##############################

#View All AWS S3 Module Commands
Get-Command -Module AWS.Tools.S3

#View S3 Buckets
Get-S3Bucket -ProfileName engr-psdemo;

#Get S3 Bucket Location
Get-S3Bucket -BucketName "engr-it" -ProfileName engr-psdemo | Get-S3BucketLocation -ProfileName engr-psdemo

#Get All Items in S3 Bucket
Get-S3Object -BucketName "engr-it" -ProfileName engr-psdemo

#Get Bucket ACL
Get-S3BucketACL -BucketName "engr-it" -ProfileName engr-psdemo

#Upload File to S3 Bucket
Write-S3Object -BucketName "engr-it" -File "C:\COEDevExport\UCD-PowerShell-Users\important-recording-01.mp4" -Key "Videos/important-recording-01.mp4" -ProfileName engr-psdemo

#Upload File to S3 Bucket Using Glacier Storage
Write-S3Object -BucketName "engr-it" -File "C:\COEDevExport\UCD-PowerShell-Users\important-recording-01.mp4" -Key "VideoArchive/important-recording-01.mp4" -StorageClass GLACIER -ProfileName engr-psdemo

# Storage Classes
# GLACIER_IR = Glacier Instant Retrieval
# GLACIER = Glacier Flexible Retrieval
# DEEP_ARCHIVE = Glacier Deep Archive

#Upload Folder to S3 Bucket
Write-S3Object -BucketName "engr-it" -Folder "C:\COEDevExport\UCD-PowerShell-Users" -KeyPrefix "PSUGroup" -Recurse -ProfileName engr-psdemo

#Create New S3 Bucket
New-S3Bucket -BucketName "psdemo-archive" -ProfileName engr-psdemo

#View Old Glacier Vaults
Get-GLCVaultList -ProfileName engr-psdemo


