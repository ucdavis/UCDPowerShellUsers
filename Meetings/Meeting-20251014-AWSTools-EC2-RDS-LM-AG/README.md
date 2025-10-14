## AWS Tools for PowerShell and EC2, RDS, Lambda, and API Gateway

Part two of the AWS Tools for PowerShell series. Covering working with EC2, RDS, Lambda, and API Gateway. 

### Resource Links

[AWS Tools for PowerShell](https://aws.amazon.com/powershell/)

[AWS Tools for PowerShell Command Reference](https://docs.aws.amazon.com/powershell/v5/reference/)

[Cloud UC Davis](https://cloud.ucdavis.edu/)

[Installed AWS Tools for PowerShell on AWS CloudShell](https://docs.aws.amazon.com/powershell/v5/userguide/pstools-getting-set-up-cloudshell.html)

### General Commands

Setting Default AWS Region for Session
```powershell
Set-DefaultAWSRegion -Region us-west-2;
```

View Configured AWS Credentials Profiles
```powershell
Get-AWSCredential -ListProfileDetail;
```

### EC2 Commands

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

### RDS Commands

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

Custom View of RDS DB Instance Ping Status
```powershell
Get-RDSDBInstance -ProfileName engr-psdemo | Foreach-Object { 
 $cstRDSPingStatus = [PSCustomObject]@{ 
 			                            DBInstanceIdentifier = $_.DBInstanceIdentifier
 				                        EndPointAddress      = $_.EndPoint.Address
 				                        EndPointPort         = $_.EndPoint.Port
 				                        PingPortStatus       = (Test-Connection -ComputerName $_.EndPoint.Address -TcpPort $_.EndPoint.Port)
 				                      }
 $cstRDSPingStatus | Select-Object -Property DBInstanceIdentifier,EndPointAddress,EndPointPort,PingPortStatus } | Format-Table -AutoSize
```

View RDS DB Snapshots
```powershell
Get-RDSDBSnapshot -ProfileName engr-psdemo | Select-Object -Property DBInstanceIdentifier,DBSnapshotIdentifier,Engine,EngineVersion,SnapshotCreateTime,SnapshotType | Format-Table -AutoSize
```

### Lambda Commands

View All Lambda Module Commands
```powershell
Get-Command -Module AWS.Tools.Lambda
```

View Lambda Functions
```powershell
Get-LMFunctionList -ProfileName engr-psdemo
```

View Basics of Individual Lambda Function Objects
```powershell
Get-LMFunctionList -ProfileName engr-psdemo | Get-LMFunction -ProfileName engr-psdemo
```

View Configuration of Lambda Functions
```powershell
Get-LMFunctionList -ProfileName engr-psdemo | Get-LMFunction -ProfileName engr-psdemo | Foreach-Object { $_.Configuration } | Format-List
```

View Code Download Links for Lambda Functions
```powershell
Get-LMFunctionList -ProfileName engr-psdemo | Get-LMFunction -ProfileName engr-psdemo | Foreach-Object { $_.Code } | Format-List
```

Download Zip File of Related Code for Lambda Functions
```powershell
Get-LMFunctionList -ProfileName engr-psdemo | Get-LMFunction -ProfileName engr-psdemo | Foreach-Object { 
		if([string]::IsNullOrEmpty($_.Code.Location) -eq $false)
		{
		    Invoke-RestMethod -Uri $_.Code.Location -OutFile ($_.Configuration.FunctionName + ".zip")
		}
}
```

### API Gateway Commands

View All AWS API Gateway Module Commands
```powershell
Get-Command -Module AWS.Tools.APIGateway
```

View List of Rest APIs
```powershell
Get-AGRestAPIList -ProfileName engr-psdemo
```

View Rest APIs Resources (still a work in progress)
```powershell
Get-AGRestAPIList -ProfileName engr-psdemo | Foreach-Object { Get-AGResourceList -RestApiId $_.Id -ProfileName engr-psdemo } | Format-Table 
```















