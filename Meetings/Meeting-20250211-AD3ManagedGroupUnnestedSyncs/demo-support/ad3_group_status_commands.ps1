<#
    Title: ad3_group_status_commands.ps1
    Authors: Dean Bunn
    Last Edit: 2025-02-10
#>

#Stopping an Accidental Run
exit; 

#COE-SW-Empire
(New-Object DirectoryServices.DirectoryEntry("LDAP://ad3.ucdavis.edu/<GUID=c462cf19-195a-4071-8273-02277b426a17>")).Properties["member"]

#COE-SW-Republic
(New-Object DirectoryServices.DirectoryEntry("LDAP://ad3.ucdavis.edu/<GUID=23e83beb-f5d6-476a-b1c7-505da5a9d0ad>")).Properties["member"]

#COE-SW-Inner-Rim
(New-Object DirectoryServices.DirectoryEntry("LDAP://ad3.ucdavis.edu/<GUID=6b0fd000-5dbd-4fe1-9d25-4d01dfcd7b35>")).Properties["member"]

#COE-SW-Outer-Rim
(New-Object DirectoryServices.DirectoryEntry("LDAP://ad3.ucdavis.edu/<GUID=b4961625-87fc-4aec-bc72-7201880b2e79>")).Properties["member"]


<#
==========================================================
c462cf19-195a-4071-8273-02277b426a17 = COE-SW-Empire
==========================================================
23e83beb-f5d6-476a-b1c7-505da5a9d0ad = COE-SW-Republic 
==========================================================
6fead534-0c18-4d98-8219-d9acc7d0e9aa = COE-SW-Coruscant
==========================================================
eba03ec8-df4f-4849-8b46-d652e3571429 = COE-SW-Kamino
==========================================================
6b0fd000-5dbd-4fe1-9d25-4d01dfcd7b35 = COE-SW-Inner-Rim
2eabeafb-b963-499c-81ee-103be4459a02 = COE-SW-Jakku
==========================================================
b4961625-87fc-4aec-bc72-7201880b2e79 = COE-SW-Outer-Rim
4bda141b-06c0-4c34-9ac3-cac0cc605bd2 = COE-SW-Geonosis
9ae46aa4-06ab-47c6-b256-aa0040c1fc80 = COE-SW-Mustafar
7ed4f50a-df55-4b68-9c91-e77c9e60b2a4 = COE-SW-Tatooine
ac6d422b-0cf4-4a61-8858-2999a95c5bc6 = COE-SW-Yavin
==========================

#>