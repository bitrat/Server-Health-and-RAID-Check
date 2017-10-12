# Copy Files and ReportHTML Module to Server into correct locations

# Map server drive
$server = "\\ABC-TECH-Server\c$\" ## enter current source folder
$wkstation = "C:\HealthCheck\" ## enter your destination folder 
$serverModule = "\\ABC-TECH-Server\c$\Program Files\WindowsPowerShell\Modules"
$wkstationModule = "C:\HealthCheck\ReportHTML"

#Copy HealthCheck folder
Copy-Item $wkstation -Destination $server -Recurse -Force

#Copy ReportHTML module 
Copy-Item $wkstationModule -Destination $serverModule -Recurse -Force