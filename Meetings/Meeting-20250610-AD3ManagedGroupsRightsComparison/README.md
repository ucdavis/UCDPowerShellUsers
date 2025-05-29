## AD3 Managed Groups Rights Check

A script to quickly determine the AD3 managed groups one user account doesn't have owner or manager rights to modify. 

### Script Summary

- Pull the AD3 managed groups that a comparison account has owner or manager rights on
- Then retreive all the AD3 managed groups the individual benchmark user or members of the benchmark AD3 group have owner or manager rights on
- Compare the two listings and report out groups the comparison admin needs access to configure

### Requirements

- The .NET System.DirectoryServices namespace installed on the system.
- The system must be joined to the uConnect AD3 AD