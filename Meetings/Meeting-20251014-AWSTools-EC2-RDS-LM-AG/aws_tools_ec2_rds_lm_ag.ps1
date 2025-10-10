<#
    Title: aws_tools_ec2_rds_lm_ag.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2025-10-09
#>

#Stopping an Accidental Run
Exit;

#Setting Default AWS Region for Session
Set-DefaultAWSRegion -Region us-west-2; 

#View Configured AWS Credentials Profiles
Get-AWSCredential -ListProfileDetail; 

#View All AWS EC2 Module Commands
Get-Command -Module AWS.Tools.EC2 

#View EC2 Instances
Get-EC2Instance -ProfileName engr-psdemo

#View Status Information of EC2 Instances
Get-EC2InstanceStatus -IncludeAllInstance $true -ProfileName engr-psdemo

#View Status State of EC2 Instances
(Get-EC2InstanceStatus -IncludeAllInstance $true -ProfileName engr-psdemo).InstanceState

#Custom View EC2 Instances Information
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

#View EC2 Volumes
Get-EC2Volume -ProfileName engr-psdemo

#View Basic EC2 Volume Status Information
Get-EC2VolumeStatus -ProfileName engr-psdemo

#Custom View of EC2 Volumes Status Information 
Get-EC2VolumeStatus -ProfileName engr-psdemo | Foreach-Object { 
$cstEC2Vol = [PSCustomObject]@{
				                VolumeID            = $_.VolumeId
				                IOEnabled           = ($_.VolumeStatus.Details | Where-Object {$_.Name -eq "io-enabled"}).Status
				                IOPerformance       = ($_.VolumeStatus.Details | Where-Object {$_.Name -eq "io-performance"}).Status
				                InitializationState = ($_.VolumeStatus.Details | Where-Object {$_.Name -eq "initialization-state"}).Status
			                  }
				
$cstEC2Vol | Select-Object -Property VolumeID,IOEnabled,IOPerformance,InitializationState } | Format-Table -AutoSize


#View All AWS RDS Module Commands
Get-Command -Module AWS.Tools.RDS

#View RDS DB Instances
Get-RDSDBInstance -ProfileName engr-psdemo

#Custom View of RDS DB Instances Status Information
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

#View RDS DB Snapshots
Get-RDSDBSnapshot -ProfileName engr-psdemo | Select-Object -Property DBInstanceIdentifier,DBSnapshotIdentifier,Engine,EngineVersion,SnapshotCreateTime,SnapshotType | Format-Table -AutoSize



