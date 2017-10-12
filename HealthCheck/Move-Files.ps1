﻿# Move Reports From Server to a Workstation

# Map server drive
$server = "\\ABC-TECH-Server\c$\HealthCheck\" ## enter current source folder
$wkstation = "C:\HealthCheck\" ## enter your destination folder 

Get-ChildItem -Path "$($server)*.csv" -Recurse | Move-Item -Destination $wkstation
Get-ChildItem -Path "$($server)*.html" -Recurse | Move-Item -Destination $wkstation