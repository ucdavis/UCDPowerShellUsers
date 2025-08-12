## AWS Tools for PowerShell and S3

Installing the AWS Tools for PowerShell and working with S3 data. 

### Resource Links

[AWS Tools for PowerShell](https://aws.amazon.com/powershell/)

[AWS Tools for PowerShell Command Reference](https://docs.aws.amazon.com/powershell/v5/reference/)

[Cloud UC Davis](https://cloud.ucdavis.edu/)

### Commands

Install AWS PowerShell Module
```powershell
Install-Module -Name AWSPowerShell.NetCore -Scope CurrentUser;
```

Check to See If Module was Successfully Installed
```powershell
Get-Module -ListAvailable;
```

Import AWS PowerShell Module
```powershell
Import-Module -Name AWSPowerShell.NetCore;
```

Get AWS PowerShell Version
```powershell
Get-AWSPowerShellVersion -ListServiceVersionInfo;
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