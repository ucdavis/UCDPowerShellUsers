<#
    Title: aws_services_config_export.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2025-10-13
#>

#Setting Default AWS Region for Session
Set-DefaultAWSRegion -Region us-west-2;

#Array for EC2 Instance Information
$arrEC2Reporter = @();

#Var for EC2 Report Name
#[string]$rptEC2Name = "AWS_Report_EC2_Instances_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv";

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
                           
# Add Custom EC2 Information to EC2 Reporting Array
$arrEC2Reporter += $cstEC2 

}

#Export EC2 Information to CSV 
$arrEC2Reporter | Select-Object -Property Name,InstanceType,InstanceID,State,PrivateIPAddress,PublicIPAddress,SubnetID,VpcID,Platform | Export-Csv -Path ("AWS_Report_EC2_Instances_" + (Get-Date).ToString("yyyy-MM-dd-HH-mm") + ".csv") -NoTypeInformation;

#Display EC2 Information to Console
$arrEC2Reporter | Select-Object -Property Name,InstanceType,InstanceID,State,PrivateIPAddress,PublicIPAddress,SubnetID,VpcID,Platform