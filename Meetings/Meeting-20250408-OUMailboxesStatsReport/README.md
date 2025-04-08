## OU Mailboxes Stats Report

A quick solution to get mailbox statistics for AD accounts in a specific department OU.

### Requirements

- The ExchangeOnlineManagement module installed. See [Commands for Required Module](commands_for_required_module.ps1) script for installation commands
- The account running the shell session must be in one of the uConnect RBAC "\<dept\>-MSGADMINS" groups
- The .NET System.DirectoryServices namespace installed on the system.
- The system must be joined to the uConnect AD3 AD
