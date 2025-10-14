<#
    Title: aws_services_reporter.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2025-10-14
#>

#Setting Default AWS Region for Session
Set-DefaultAWSRegion -Region us-west-2;

#Var for AWS Profile Name
[string]$awsProfile = "engr-psdemo";

#Array for EC2 Instance Reporting
$arrEC2Reporter = @();

#Array for EC2 Volume Reporting
$arrEC2VolumeRptr = @();

#Array for RDS Reporting
$arrRDSReporter = @();

#Report EC2 Status
Get-EC2Instance -ProfileName $awsProfile | ForEach-Object { 
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
                           
# Add Custom EC2 Information to EC2 Reporting Array
$arrEC2Reporter += $cstEC2 

}

#Export EC2 Information to CSV 
$arrEC2Reporter | Select-Object -Property Name,InstanceType,InstanceID,State,PrivateIPAddress,PublicIPAddress,SubnetID,VpcID,Platform | Export-Csv -Path ("AWS_Report_EC2_Instances_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv") -NoTypeInformation;

#Display EC2 Information to Console
$arrEC2Reporter | Select-Object -Property Name,InstanceType,InstanceID,State,PrivateIPAddress,PublicIPAddress,SubnetID,VpcID,Platform | Format-Table -AutoSize

#Report EC2 Volume Information
Get-EC2VolumeStatus -ProfileName $awsProfile | Foreach-Object { 
$cstEC2Vol = [PSCustomObject]@{
				                VolumeID            = $_.VolumeId
				                IOEnabled           = ($_.VolumeStatus.Details | Where-Object {$_.Name -eq "io-enabled"}).Status
				                IOPerformance       = ($_.VolumeStatus.Details | Where-Object {$_.Name -eq "io-performance"}).Status
				                InitializationState = ($_.VolumeStatus.Details | Where-Object {$_.Name -eq "initialization-state"}).Status
			                  }
# Add Custom Object to Report Array
$arrEC2VolumeRptr += $cstEC2Vol 
}

#Export EC2 Volume Information to CSV
$arrEC2VolumeRptr | Select-Object -Property VolumeID,IOEnabled,IOPerformance,InitializationState | Export-Csv -Path ("AWS_Report_EC2_Volumes_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv") -NoTypeInformation;

#Display EC2 Volume Information to Console
$arrEC2VolumeRptr | Select-Object -Property VolumeID,IOEnabled,IOPerformance,InitializationState | Format-Table -AutoSize

Get-RDSDBInstance -ProfileName $awsProfile | Foreach-Object { 
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
# Add Custom Object to Reporting Array
$arrRDSReporter += $cstRDS 
} 

#Export RDS Instance Information to CSV
$arrRDSReporter | Select-Object -Property DBIdentifier,DBInstanceStatus,DBInstanceClass,Engine,EngineVersion,LatestRestorableTime,PubliclyAccessible,EndPointAddress,EndPointPort | Export-Csv -Path ("AWS_Report_RDS_Instances_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv") -NoTypeInformation;

#Display RDS Instance Information to Console
$arrRDSReporter | Select-Object -Property DBIdentifier,DBInstanceStatus,DBInstanceClass,Engine,EngineVersion,LatestRestorableTime,PubliclyAccessible,EndPointAddress,EndPointPort | Format-Table -AutoSize

#Export Lambda Function Basic Information to CSV
Get-LMFunctionList -ProfileName $awsProfile | Select-Object -Property FunctionName,Runtime,MemorySize,Timeout,CodeSize,LastModified,Role | Export-Csv -Path ("AWS_Report_Lambda_Functions_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv") -NoTypeInformation;

#Display Lambda Functions
Get-LMFunctionList -ProfileName $awsProfile | Select-Object -Property FunctionName,Runtime,MemorySize,Timeout,CodeSize,LastModified,Role | Format-Table -AutoSize

#Download Zip File of Related Code for Lambda Functions
Get-LMFunctionList -ProfileName $awsProfile | Get-LMFunction -ProfileName $awsProfile | Foreach-Object { 
		if([string]::IsNullOrEmpty($_.Code.Location) -eq $false)
		{
		    Invoke-RestMethod -Uri $_.Code.Location -OutFile ($_.Configuration.FunctionName + ".zip")
		}
}

#Export API Gateway APIs
Get-AGRestAPIList -ProfileName $awsProfile | Foreach-Object { Get-AGResourceList -RestApiId $_.Id -ProfileName $awsProfile } | Select-Object -Property Id,ParentId,Path,PathPart | Export-Csv -Path ("AWS_Report_API_Gateway_APIs_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv") -NoTypeInformation;

#Display API Gateway APIs
Get-AGRestAPIList -ProfileName $awsProfile | Foreach-Object { Get-AGResourceList -RestApiId $_.Id -ProfileName $awsProfile } | Format-Table  

#Export S3 Bucket List
Get-S3Bucket -ProfileName $awsProfile | Select-Object -Property BucketName,BucketArn,BucketRegion,CreationDate | Export-Csv -Path ("AWS_Report_S3_Buckets_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv") -NoTypeInformation;

#Display S3 Bucket List
Get-S3Bucket -ProfileName $awsProfile | Select-Object -Property BucketName,BucketArn,BucketRegion,CreationDate | Format-Table -AutoSize






























