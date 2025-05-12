## DNS Record Report

### Required Setup

- The system must be joined to the uConnect AD3 AD
- The PowerShell Active Directory and DNS Server Modules must be installed on the local system. 

```powershell
Install-WindowsFeature -ComputerName localhost -Name 'RSAT-AD-PowerShell','RSAT-DNS-Server'
#Features Listed Under: Remote Server Administration Tools -> Role Administration Tools 
```

### Script Summary

1. Look up all enabled computers in each listed OU path
2. Pull the last login timestamp of each computer
3. Pull DNS A records for each computer
4. Create CSV reports. One of active computers with DNS records and the other of computers without a DNS record

