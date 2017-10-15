# Copy Files and ReportHTML Module to Server into correct locations

# Map server drive
$server = "\\ABC-TECH-Server\c$\" ## enter current source folder
$wkstation = "C:\HealthCheck\" ## enter your destination folder 
$serverModule = "\\ABC-TECH-Server\c$\Program Files\WindowsPowerShell\Modules"
$wkstationModule1 = "C:\HealthCheck\ModulesToCopy\ReportHTML"
$wkstationModule2 = "C:\HealthCheck\ModulesToCopy\ImportExcel"

#Copy HealthCheck folder
Copy-Item $wkstation -Destination $server -Recurse -Force

#Copy ReportHTML module 
Copy-Item $wkstationModule1 -Destination $serverModule -Recurse -Force

#Copy ImportExcel module 
Copy-Item $wkstationModule2 -Destination $serverModule -Recurse -Force