# Find New Users added into the Default AD Users Container 
# and moves them to the most Locked down OU and Security Group
# Setup Scheduled Task to keep AD Users Container clean

# Find users added in last 15 minutes
$now = (Get-Date).AddMinutes(-15)
#Get-ADUser -Filter {whenCreated -ge $now}

# Find users created in last 15 min and only in Users Container
$sb = "CN=Users,DC=ABC TECH,DC=COMPANY"

$usersToMove = Get-ADUser -Filter {whenCreated -ge $now} -SearchBase $sb
#$usersToMove

try {
    foreach ($userToMove in $usersToMove) {

    # If User exists get the unique samAccountName
    $samAccount = $userToMove.SamAccountName
    $samAccount

    # Move User to most locked down security group in AD
    $userToMove | % { Add-ADGroupMember 'CN=SGF,OU=Security Groups,OU=Groups,OU=ABC,OU=Wellington,OU=NZ,DC=ABC TECH,DC=COMPANY' -Members $_ } #-WhatIf }
    Write-Host "User moved into SGF - Security Group"
    # Move this user into the most locked down AD OU and add to Security Group
    $userToMove | Move-ADObject -TargetPath 'OU=Standard User,OU=Users,OU=ABC,OU=Wellington,OU=NZ,DC=ABC TECH,DC=COMPANY' #-WhatIf
    Write-Host "User moved into Standard User - OU"

     # Disable Remote Control 
    $ADUser = Get-ADUser $samAccount | select -ExpandProperty disting*
    $userAD = [ADSI]"LDAP://$ADUser"
    # Disable = 0, EnableInput Notify= 1, EnableInput NoNotify= 2, EnableNoInput Notify= 3, EnableNoInput NoNotify= 4
    $userAD.InvokeSet("EnableRemoteControl",0)
    $userAD.SetInfo()

    # Disable RDP
    # Disable = 0, Enable = 1
    $userAD.psbase.invokeSet("allowLogon",0)
    $userAD.SetInfo()

    }
}
catch {

    Write-Host "Users not able to be moved into OU or Security Group"

}

# Find Users added to Standard User OU 
# - add to SGF Security group
# - disable remote control and RDP

# Find users created in last 15 min and only in Users Container
$SGFsb = "OU=Standard User,OU=Users,OU=ABC,OU=Wellington,OU=NZ,DC=ABC TECH,DC=COMPANY"

$SGFusersToMove = Get-ADUser -Filter {whenCreated -ge $now} -SearchBase $SGFsb
#$usersToMove

try {
    foreach ($SGFuserToMove in $SGFusersToMove) {

    # If User exists get the unique samAccountName
    $SGFsamAccount = $SGFuserToMove.SamAccountName
    $SGFsamAccount

    # Move User to most locked down security group in AD
    $SGFuserToMove | % { Add-ADGroupMember 'CN=SGF,OU=Security Groups,OU=Groups,OU=ABC,OU=Wellington,OU=NZ,DC=ABC TECH,DC=COMPANY' -Members $_ } #-WhatIf }
    Write-Host "User moved into SGF - Security Group"

     # Disable Remote Control 
    $SGFADUser = Get-ADUser $SGFsamAccount | select -ExpandProperty disting*
    $SGFuserAD = [ADSI]"LDAP://$SGFADUser"
    # Disable = 0, EnableInput Notify= 1, EnableInput NoNotify= 2, EnableNoInput Notify= 3, EnableNoInput NoNotify= 4
    $SGFuserAD.InvokeSet("EnableRemoteControl",0)
    $SGFuserAD.SetInfo()

    # Disable RDP
    # Disable = 0, Enable = 1
    $SGFuserAD.psbase.invokeSet("allowLogon",0)
    $SGFuserAD.SetInfo()

    }
}
catch {

    Write-Host "User not able to be moved into SGF - Security Group"

}

# Find Users added to DelegatedAdmins OU 
# - add to ABC DelAdmin group
# - disable remote control and RDP

# Find users created in last 15 min and only in Users Container
$DELAdminsb = "OU=DelegatedAdmins,OU=Users,OU=ABC,OU=Wellington,OU=NZ,DC=ABC TECH,DC=COMPANY"

$DELAdminusersToMove = Get-ADUser -Filter {whenCreated -ge $now} -SearchBase $DELAdminsb
#$usersToMove

try {
    foreach ($DELAdminuserToMove in $DELAdminusersToMove) {

    # If User exists get the unique samAccountName
    $DELAdminsamAccount = $DELAdminuserToMove.SamAccountName
    $DELAdminsamAccount

    # Move User to correct delegated control security group in AD
    $DELAdminuserToMove | % { Add-ADGroupMember 'CN=ABC DelAdmin,OU=Security Groups,OU=Groups,OU=ABC,OU=Wellington,OU=NZ,DC=ABC TECH,DC=COMPANY' -Members $_ } #-WhatIf }
    Write-Host "User moved into ABC DelAdmin - Security Group"

     # Disable Remote Control 
    $DELAdminADUser = Get-ADUser $DELAdminsamAccount | select -ExpandProperty disting*
    $DELAdminuserAD = [ADSI]"LDAP://$DELAdminADUser"
    # Disable = 0, EnableInput Notify= 1, EnableInput NoNotify= 2, EnableNoInput Notify= 3, EnableNoInput NoNotify= 4
    $DELAdminuserAD.InvokeSet("EnableRemoteControl",0)
    $DELAdminuserAD.SetInfo()

    # Disable RDP
    # Disable = 0, Enable = 1
    $DELAdminuserAD.psbase.invokeSet("allowLogon",0)
    $DELAdminuserAD.SetInfo()

    }
}
catch {

    Write-Host "User not able to be moved into ABC DelAdmin - Security Group"

}

