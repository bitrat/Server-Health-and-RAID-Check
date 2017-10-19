# Move Reports From Server to Workshop Workstation

# Map server drive
$server = "\\ABC-Tech-Company\c$\HealthCheck\" ## enter current source folder
$wkstation = "C:\HealthCheck\" ## enter your destination folder 

# Move files from specified folder - if files are older than a day
# This prevents files that are currently being written to, from being moved
Get-Childitem -Path "$($server)*.csv" |
    Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-1)} | 
    Move-Item -destination $wkstation

Get-Childitem -Path "$($server)*.html" |
    Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-1)} | 
    Move-Item -destination $wkstation

# Move files from specified folder, including today's files
#Get-ChildItem -Path "$($server)*.csv" | Move-Item -Destination $wkstation
#Get-ChildItem -Path "$($server)*.html" | Move-Item -Destination $wkstation

# Move files from subfolders as well
#Get-ChildItem -Path "$($server)*.csv" -Recurse | Move-Item -Destination $wkstation
#Get-ChildItem -Path "$($server)*.html" -Recurse | Move-Item -Destination $wkstation