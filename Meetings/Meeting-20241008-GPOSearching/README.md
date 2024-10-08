## GPO Searching

### Requirements

- Active Directory and Group Policy PowerShell modules installed on system running script

### Script Summary

- Query from Active Directory all OUs including the search base parent OU
- Gather a list of unique GPO IDs linked to those OUs
- Pull the settings report in HTML format for each of those OUs and look for the specified search terms
- Display the names of the GPOs that contain the found search terms

