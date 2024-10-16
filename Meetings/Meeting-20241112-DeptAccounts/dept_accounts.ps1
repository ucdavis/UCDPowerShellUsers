<#
    Title: dept_accounts.ps1
    Authors: Dean Bunn and Ben Clark
    Last Edit: 2024-11-12
#>

#Var for Department Code
[string]$deptCode = "024025";

#Import Active Directory Module
Import-Module ActiveDirectory;

#Var for AD Fully Qualified Domain Name
[string]$dmnFQDN = "ad3.ucdavis.edu";

#Var for Search Base
[string]$adSrchBase = "OU=ucdUsers,DC=ad3,DC=ucdavis,DC=edu";

#Array of Addition Group Properties to Retrieve
[string[]]$arrUsrProps = "displayName","extensionAttribute5","extensionAttribute7";

#Var for LDAP Filter
[string]$adLDAPFilter = "(&(objectclass=user)(extensionAttribute11=D)(|(department=" + $deptCode + ")(departmentNumber=" + $deptCode + ")(extensionAttribute9=*" + $deptCode + "*)))";

$ad3DeptAccounts = Get-ADUser -LDAPFilter $adLDAPFilter -SearchBase $adSrchBase -server $dmnFQDN -Properties $arrUsrProps;

$ad3DeptAccounts
