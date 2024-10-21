## Department Accounts

### Requirements

- Active Directory module installed on system running script

### Script Summary

- Query from Active Directory all departmental accounts associated with provided six digit department codes
- Create custom reporting objects and load them with specific properties from returned AD accounts
- Using IAM owner ID stored in an extension attribute value of the departmental account, pull the owner account and add relevent identity and contact information to the custom object
- Report out all findings to CSV file


