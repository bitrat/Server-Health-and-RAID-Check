#Remove Directory from server

# Map server drive to remove
$server = "\\ABC-Tech-Company\c$\HealthCheck\" 
#$wkstation = "C:\HealthCheck3\" ## local folder to remove

#Remove HealthCheck folder
Remove-Item -path $wkstation -Force #-WhatIf
