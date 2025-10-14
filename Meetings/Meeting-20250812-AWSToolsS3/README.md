## AWS Tools for PowerShell and S3

Installing the AWS Tools for PowerShell and working with the S3 module. 

### Resource Links

[AWS Tools for PowerShell](https://aws.amazon.com/powershell/)

[AWS Tools for PowerShell Command Reference](https://docs.aws.amazon.com/powershell/v5/reference/)

[Cloud UC Davis](https://cloud.ucdavis.edu/)

[Installed AWS Tools for PowerShell on AWS CloudShell](https://docs.aws.amazon.com/powershell/v5/userguide/pstools-getting-set-up-cloudshell.html)

### General Commands

Install AWS Tools Installer Module
```powershell
Install-Module -Name AWS.Tools.Installer -Scope CurrentUser
```

View Installed Modules
```powershell
Get-InstalledModule 
```

View Full List of Available Modules
```powershell
Get-Module -ListAvailable;
```

Install AWS Tools Common Module Using AWS Tools Installer
```powershell
Install-AWSToolsModule AWS.Tools.Common -CleanUp
```

Get AWS PowerShell Version and View More Extensive List of AWS PowerShell Module Names
```powershell
Get-AWSPowerShellVersion -ListServiceVersionInfo | Format-Table -AutoSize
```

Install Various AWS Modules
```powershell
Install-AWSToolsModule AWS.Tools.S3,AWS.Tools.RDS,AWS.Tools.APIGateway,AWS.Tools.EC2,AWS.Tools.Lambda -CleanUp
```
```powershell
# AWS.Tools.APIGateway
# AWS.Tools.EC2
# AWS.Tools.Glacier
# AWS.Tools.Lambda
# AWS.Tools.RDS
# AWS.Tools.S3
```

Update Installed AWS Tools Modules
```powershell
Update-AWSToolsModule -CleanUp
```

View Commands Listed in a Module
```powershell
Get-Command -Module AWS.Tools.Common
```

Get List of AWS Regions
```powershell
Get-AWSRegion;
```

Setting Default AWS Region for Session
```powershell
Set-DefaultAWSRegion -Region us-west-2;
```

View Default AWS Region
```powershell
Get-DefaultAWSRegion;
```

Set AWS Credentials
```powershell
Set-AWSCredential -AccessKey BIGACCESSKEYSTRING -SecretKey VeryLongSecretKey -StoreAs engr-psdemo
```

Get List of AWS Credentials 
```powershell
Get-AWSCredential -ListProfileDetail; 
```

### S3 Commands

View S3 Buckets 
```powershell
Get-S3Bucket -ProfileName engr-psdemo;
```

Get S3 Bucket Location
```powershell
Get-S3Bucket -BucketName "engr-it" -ProfileName engr-psdemo | Get-S3BucketLocation -ProfileName engr-psdemo
```

Get All Items in S3 Bucket 
```powershell
Get-S3Object -BucketName "engr-it" -ProfileName engr-psdemo
```

Upload File to S3 Bucket
```powershell
Write-S3Object -BucketName "engr-it" -File "C:\COEDevExport\UCD-PowerShell-Users\important-recording-01.mp4" -Key "Videos/important-recording-01.mp4" -ProfileName engr-psdemo;
```

Upload File to S3 Bucket Using Glacier Storage
```powershell
Write-S3Object -BucketName "engr-it" -File "C:\COEDevExport\UCD-PowerShell-Users\important-recording-01.mp4" -Key "VideoArchive/important-recording-01.mp4" -StorageClass GLACIER -ProfileName engr-psdemo
```
```powershell
# Storage Classes
# GLACIER_IR = Glacier Instant Retrieval
# GLACIER = Glacier Flexible Retrieval
# DEEP_ARCHIVE = Glacier Deep Archive
```

Upload Folder to S3 Bucket 
```powershell
Write-S3Object -BucketName "engr-it" -Folder "C:\COEDevExport\UCD-PowerShell-Users" -KeyPrefix "PSUGroup" -Recurse -ProfileName engr-psdemo;
```

Create New S3 Bucket
```powershell
New-S3Bucket -BucketName "psdemo-archive" -ProfileName engr-psdemo
```

View Old Glacier Vaults
```powershell
Get-GLCVaultList -ProfileName engr-psdemo
```