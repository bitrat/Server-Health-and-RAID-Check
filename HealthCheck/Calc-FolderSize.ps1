#Calculate specific Folder size
$server = '\\ABC-TechCompany\C$\Photos\'

$FolderList = Get-ChildItem $server
Foreach($Folder in $FolderList)
{

    $FolderSize = Get-ChildItem "$server$Folder" -Recurse | Measure-Object -property length -sum
	
	$Folder.Name + " - " + ($FolderSize.Sum/1mb) + " MB"
}

