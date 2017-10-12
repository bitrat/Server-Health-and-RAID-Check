# List Files on C:\Drive to find out where Backups and Archives are Stored

# Map server drive
$server = "\\ABC-TECH-Server\c$\" ## enter current source folder
$wkstation = "C:\" ## enter your destination folder 

#Get-ChildItem $wkstation -Directory # -Recurse -Force
Get-ChildItem $server -Directory # -Recurse -Force