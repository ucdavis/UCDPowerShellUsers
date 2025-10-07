## AWS Tools for PowerShell and S3

Installing the AWS Tools for PowerShell and working with S3 data. 

### Resource Links

[AWS Tools for PowerShell](https://aws.amazon.com/powershell/)

[AWS Tools for PowerShell Command Reference](https://docs.aws.amazon.com/powershell/v5/reference/)

[Cloud UC Davis](https://cloud.ucdavis.edu/)

[Installed AWS Tools for PowerShell on AWS CloudShell](https://docs.aws.amazon.com/powershell/v5/userguide/pstools-getting-set-up-cloudshell.html)

### Commands

Install AWS Tools Installer Module
```powershell
Install-Module -Name AWS.Tools.Installer -Scope CurrentUser
```

Check to See If Module was Successfully Installed
```powershell
Get-Module -ListAvailable;
```

Install AWS Tools Common Module Using AWS Tools Installer
```powershell
Install-AWSToolsModule AWS.Tools.Common -CleanUp
```

Get AWS PowerShell Version and View More Extensive List of AWS PowerShell Module Names
```powershell
Get-AWSPowerShellVersion -ListServiceVersionInfo;
```

Install Various AWS Modules
```powershell
Install-AWSToolsModule AWS.Tools.S3,AWS.Tools.RDS,AWS.Tools.APIGateway,AWS.Tools.EC2,AWS.Tools.Lambda -CleanUp

#AWS.Tools.APIGateway
#AWS.Tools.EC2
#AWS.Tools.Lambda
#AWS.Tools.RDS
#AWS.Tools.S3
```

Update Installed AWS Tools Modules
```powershell
Update-AWSToolsModule -CleanUp
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
Set-AWSCredential -AccessKey BIGACCESSKEYSTRING -SecretKey VeryLongSecretKey -StoreAs engr-demo
```

Get List of AWS Credentials 
```powershell
Get-AWSCredential -ListProfileDetail; 
```

View S3 Buckets 
```powershell
Get-S3Bucket -ProfileName engr-viewer;
```

Get S3 Bucket Location
```powershell
Get-S3Bucket -ProfileName engr-viewer | Get-S3BucketLocation -ProfileName engr-viewer
```

Get All Items in S3 Bucket 
```powershell
Get-S3Bucket -ProfileName engr-viewer | Get-S3Object -ProfileName engr-viewer
```

Upload File to S3 Bucket
```powershell
Write-S3Object -BucketName "engr-it" -File "C:\COEDevExport\MAE257-Spring2025.mp4" -Key "Videos/MAE257-Week1-Spring2025.mp4" -ProfileName engr-uploader;
```

Upload Folder to S3 Bucket 
```powershell
Write-S3Object -BucketName "engr-it" -Folder "C:\COEDevExport\PowerShellUsersGroup" -KeyPrefix "PSUGroup" -Recurse -ProfileName engr-uploader;
```