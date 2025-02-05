## OU Mailboxes Report

A quick solution to get all the Office365 mailboxes in your department OU. 

Change line 9 with the name of OU of your department under the "Departments" OU
```powershell
[string]$dptOU = "COE";
```

### Requirements

- The .NET System.DirectoryServices namespace installed on the system.
- The system must be joined to the uConnect AD3 AD