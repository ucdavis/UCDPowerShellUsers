## AD3 Managed Groups Rights Check

A script to quickly determine the AD3 managed groups one admin account doesn't have owner or manager rights to modify. 

### Script Summary

- Pull the AD3 Managed groups that a comparison admin account has owner or manager rights on
- Then retreive all the members of a specified AD group consisting of other AD3 admins accounts
- Pull all the AD3 Managed groups each of the other admins have access to modify
- Compare the two listings and report out groups the comparison admin needs access to configure

### Requirements

- The .NET System.DirectoryServices namespace installed on the system.
- The system must be joined to the uConnect AD3 AD