## AD3 Offboarding

### Requirements

- An uInform API access key for your AD3 admin account
- Active Directory PowerShell modules installed on system running script
- Setting up PowerShell Secrets vault

### Script Summary

1. Loads uInform API keys from secrets vault
2. Pulls all AD3 managed groups the Admin account has owner or manager rights on
3. Pull the offboarded members group membership and compares that to the list the Admin account has access to
4. For regular managed groups and groups the offboarded member has manager rights it removes those memberships. Ownership rights for the offboarded member will only be removed if the Admin account already has ownership rights to the managed group