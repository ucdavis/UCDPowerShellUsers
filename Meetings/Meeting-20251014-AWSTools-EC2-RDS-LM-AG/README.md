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

View All AWS EC2 Module Commands
```powershell
Get-Command -Module AWS.Tools.EC2
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

Custom View EC2 Instances Information
```powershell
Get-EC2Instance -ProfileName engr-psdemo | ForEach-Object { 
$cstEC2 = [PSCustomObject]@{
                             Name              =  ($_.Instances.Tags | Where-Object {$_.Key -eq "Name"}).Value
                             InstanceID        =  $_.Instances.InstanceId
                             InstanceType      =  $_.Instances.InstanceType
                             PrivateIpAddress  =  $_.Instances.PrivateIpAddress
                             PublicIPAddress   =  $_.Instances.PublicIpAddress
                             SubnetID          =  $_.Instances.SubnetId
                             VpcID             =  $_.Instances.VpcId
                             State             =  $_.Instances.State.Name
                             Platform          =  $_.Instances.PlatformDetails
                           }
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

Custom View of EC2 Volumes Status Information 
```powershell
Get-EC2VolumeStatus -ProfileName engr-psdemo | Foreach-Object { 
$cstEC2Vol = [PSCustomObject]@{
				                VolumeID            = $_.VolumeId
				                IOEnabled           = ($_.VolumeStatus.Details | Where-Object {$_.Name -eq "io-enabled"}).Status
				                IOPerformance       = ($_.VolumeStatus.Details | Where-Object {$_.Name -eq "io-performance"}).Status
				                InitializationState = ($_.VolumeStatus.Details | Where-Object {$_.Name -eq "initialization-state"}).Status
			                  }
				
$cstEC2Vol | Select-Object -Property VolumeID,IOEnabled,IOPerformance,InitializationState } | Format-Table -AutoSize
```

View All AWS RDS Module Commands
```powershell
Get-Command -Module AWS.Tools.RDS
```

View RDS DB Instances
```powershell
Get-RDSDBInstance -ProfileName engr-psdemo
```

Custom View of RDS DB Instances Status Information
```powershell
Get-RDSDBInstance -ProfileName engr-psdemo | Foreach-Object { 
$cstRDS = [PSCustomObject]@{
                		     DBIdentifier  	      = $_.DBInstanceIdentifier
                		     DBInstanceStatus     = $_.DBInstanceStatus
                		     DBInstanceClass      = $_.DBInstanceClass
                		     Engine               = $_.Engine
                		     EngineVersion        = $_.EngineVersion
                		     LatestRestorableTime = $_.LatestRestorableTime
                		     PubliclyAccessible   = $_.PubliclyAccessible
                		     EndPointAddress      = $_.EndPoint.Address
                		     EndPointPort         = $_.EndPoint.Port
            		        }
$cstRDS | Select-Object -Property DBIdentifier,DBInstanceStatus,DBInstanceClass,Engine,EngineVersion,LatestRestorableTime,PubliclyAccessible,EndPointAddress,EndPointPort } | Format-Table -AutoSize
```

View RDS DB Snapshots
```powershell
Get-RDSDBSnapshot -ProfileName engr-psdemo | Select-Object -Property DBInstanceIdentifier,DBSnapshotIdentifier,Engine,EngineVersion,SnapshotCreateTime,SnapshotType | Format-Table -AutoSize
```