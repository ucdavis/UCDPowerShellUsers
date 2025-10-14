<#
    Title: aws_tools_ec2_rds_lm_ag.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2025-10-14
#>

#Stopping an Accidental Run
Exit;

#Setting Default AWS Region for Session
Set-DefaultAWSRegion -Region us-west-2; 

#View Configured AWS Credentials Profiles
Get-AWSCredential -ListProfileDetail; 

#############################
# EC2
#############################

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

#############################
# RDS
#############################

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

#Custom View of RDS DB Instance Ping Status
 Get-RDSDBInstance -ProfileName engr-psdemo | Foreach-Object { 
 $cstRDSPingStatus = [PSCustomObject]@{ 
 			                            DBInstanceIdentifier = $_.DBInstanceIdentifier
 				                        EndPointAddress      = $_.EndPoint.Address
 				                        EndPointPort         = $_.EndPoint.Port
 				                        PingPortStatus       = (Test-Connection -ComputerName $_.EndPoint.Address -TcpPort $_.EndPoint.Port)
 				                      }
 $cstRDSPingStatus | Select-Object -Property DBInstanceIdentifier,EndPointAddress,EndPointPort,PingPortStatus } | Format-Table -AutoSize


#View RDS DB Snapshots
Get-RDSDBSnapshot -ProfileName engr-psdemo | Select-Object -Property DBInstanceIdentifier,DBSnapshotIdentifier,Engine,EngineVersion,SnapshotCreateTime,SnapshotType | Format-Table -AutoSize

#############################
# Lambda
#############################

#View All AWS Lambda Module Commands
Get-Command -Module AWS.Tools.Lambda 

#View Lambda Functions
Get-LMFunctionList -ProfileName engr-psdemo

#View Basics of Individual Lambda Function Objects
Get-LMFunctionList -ProfileName engr-psdemo | Get-LMFunction -ProfileName engr-psdemo

#View Configuration of Lambda Functions
Get-LMFunctionList -ProfileName engr-psdemo | Get-LMFunction -ProfileName engr-psdemo | Foreach-Object { $_.Configuration } | Format-List

#View Code Download Links for Lambda Functions
Get-LMFunctionList -ProfileName engr-psdemo | Get-LMFunction -ProfileName engr-psdemo | Foreach-Object { $_.Code } | Format-List

#Download Zip File of Related Code for Lambda Functions
Get-LMFunctionList -ProfileName engr-psdemo | Get-LMFunction -ProfileName engr-psdemo | Foreach-Object { 
		if([string]::IsNullOrEmpty($_.Code.Location) -eq $false)
		{
		    Invoke-RestMethod -Uri $_.Code.Location -OutFile ($_.Configuration.FunctionName + ".zip")
		}
}

#############################
# API Gateway
#############################

#View All AWS API Gateway Module Commands
Get-Command -Module AWS.Tools.APIGateway

#View List of Rest APIs
Get-AGRestAPIList -ProfileName engr-psdemo

#View Rest APIs Resources
Get-AGRestAPIList -ProfileName engr-psdemo | Foreach-Object { Get-AGResourceList -RestApiId $_.Id -ProfileName engr-psdemo } | Format-Table  












