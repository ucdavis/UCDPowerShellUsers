## AWS Tools for PowerShell and EC2, RDS, Lambda, and API Gateway

Part two of the AWS Tools for PowerShell series. Covering working with EC2, RDS, Lambda, and API Gateway. 

### Resource Links

[AWS Tools for PowerShell](https://aws.amazon.com/powershell/)

[AWS Tools for PowerShell Command Reference](https://docs.aws.amazon.com/powershell/v5/reference/)

[Cloud UC Davis](https://cloud.ucdavis.edu/)

[Installed AWS Tools for PowerShell on AWS CloudShell](https://docs.aws.amazon.com/powershell/v5/userguide/pstools-getting-set-up-cloudshell.html)

### Commands

Setting Default AWS Region for Session
```powershell
Set-DefaultAWSRegion -Region us-west-2;
```

View Configured AWS Credentials Profiles
```powershell
Get-AWSCredential -ListProfileDetail;
```

View EC2 Instances
```powershell
Get-EC2Instance -ProfileName engr-psdemo
```

View Status Information of EC2 Instances
```powershell
Get-EC2InstanceStatus -IncludeAllInstance $true -ProfileName engr-psdemo
```

View Status State of EC2 Instances
```powershell
(Get-EC2InstanceStatus -IncludeAllInstance $true -ProfileName engr-psdemo).InstanceState
```

View All EC2 Instance with Custom Instance Information
```powershell
Get-EC2Instance -ProfileName engr-psdemo | ForEach-Object { 
$cstEC2 = new-object PSObject -Property (@{Name=($_.Instances.Tags | Where-Object {$_.Key -eq "Name"}).Value;
                                           InstanceID=$_.Instances.InstanceId; 
                                           InstanceType=$_.Instances.InstanceType;
                                           PrivateIpAddress=$_.Instances.PrivateIpAddress;
                                           PublicIPAddress=$_.Instances.PublicIpAddress;
                                           SubnetID=$_.Instances.SubnetId;
                                           VpcID=$_.Instances.VpcId;
                                           State=$_.Instances.State.Name;
                                           Platform=$_.Instances.PlatformDetails;}); 
$cstEC2 | Select-Object -Property Name,InstanceType,InstanceID,State,PrivateIPAddress,PublicIPAddress,SubnetID,VpcID,Platform  } | Format-Table -AutoSize
```

View EC2 Volumes
```powershell
Get-EC2Volume -ProfileName engr-psdemo
```

View Basic EC2 Volume Status Information
```powershell
Get-EC2VolumeStatus -ProfileName engr-psdemo
```

View EC2 Volumes with Custom Status Information
```powershell
Get-EC2VolumeStatus -ProfileName engr-psdemo | Foreach-Object { 
$cstEC2Vol = new-object PSObject -Property (@{VolumeID=$_.VolumeId;
					                          IOEnabled=($_.VolumeStatus.Details | Where-Object {$_.Name -eq "io-enabled"}).Status;
					                          IOPerformance=($_.VolumeStatus.Details | Where-Object {$_.Name -eq "io-performance"}).Status;
					                          InitializationState=($_.VolumeStatus.Details | Where-Object {$_.Name -eq "initialization-state"}).Status;});
$cstEC2Vol | Select-Object -Property VolumeID,IOEnabled,IOPerformance,InitializationState} | Format-Table -AutoSize
```