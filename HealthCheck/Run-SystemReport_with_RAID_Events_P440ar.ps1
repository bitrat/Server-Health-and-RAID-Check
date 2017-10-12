# Run-SystemReport_with_RAID_Events.ps1

# Copy ReportHTML Module into C:\Program Files\WindowsPowerShell\Modules\
# Or use the Copy-FilesToServer.ps1 script

<#PSScriptInfo

.EXTERNALMODULEDEPENDENCIES ReportHTML 

#>

<# 
.DESCRIPTION 
 A computer system report run on a Gallagher Access Control Server - checks CPU use, OS info, Memory, Disk, Hotfix dates (Win 7 to Win 10), RAID Error event listing, EventLogs
 See example: http://www.azurefieldnotes.com/2016/08/04/powershellhtmlreportingpart1/
 #> 
#requires -Modules ReportHTML

# --------PARAMETERS and VARIABLES SECTION -----------------
param (
    #$thresholdspace = 80,
    [int]$EventNum = 5,
    [int]$ProccessNumToFetch = 10
)

#Assumes script is run locally - else modify RAID component to include -ComputerName switch
$Now = Get-Date
$ComputerName = $env:Computername 
$ReportOutputPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$ReportName = "ABC TECH SERVER  - "+$ComputerName+" -  System Report - P440ar RAID Controller - "+$now.Day+" "+$now.Month+" "+$now.Year

#Region Checking Backup and Archives folders
$GallagherBackup = "C:\Backup\"
$GallagherArchives = "C:\Archives\"

#Region Logos
$Logo1 = join-path $ReportOutputPath "ABC TECHLogo.jpg"
#$Logo2 = join-path $ReportOutputPath "ABC TECHLogo.jpg"
#endregion

# REGION Start RAID Error Event 
$RAID_events_reference = "C:\HealthCheck\RAID\P440ar_RAID_EventIDs.txt"
#TEST txt file
#$RAID_events_reference = "C:\HealthCheck\RAID\Test_RAID_EventIDs.txt"

# TESTING - Write to EventLog and then get Script to detect EventID 1003 and 1005
#Write-EventLog -ComputerName $ComputerName -Log "Windows PowerShell" -Source PowerShell -EventID 1001  –Message “This is a test message.”
#Write-EventLog -ComputerName $ComputerName -Log "Windows PowerShell" -Source PowerShell -EventID 1002  –Message “This is a test message.”
#Write-EventLog -ComputerName $ComputerName -Log "Windows PowerShell" -Source PowerShell -EventID 1003  –Message “This is a test message.”
#Write-EventLog -ComputerName $ComputerName -Log "Windows PowerShell" -Source PowerShell -EventID 1004  –Message “This is a test message.”
#Write-EventLog -ComputerName $ComputerName -Log "Windows PowerShell" -Source PowerShell -EventID 1005  –Message “This is a test message.”
#Write-EventLog -ComputerName $ComputerName -Log "Windows PowerShell" -Source PowerShell -EventID 1006  –Message “This is a test message.”

# TEST VALUES
#$EventLogName = "Windows PowerShell"
#$EventLogSource = "Powershell"

$EventLogName = "System"
# Check below line with CIS
#$EventLogSource = "Cissesrv"

#TEST Event Ids - $EventIDs = @(1003,1005) - Create and reference (see start of script) Test_RAID_EventIDs.txt 
$EventIDs = Get-Content $RAID_events_reference

# Define Time to check events 
# Check last 7 days 
$TimeToCheck = 7
$TimeSpan = New-Timespan -Days $TimeToCheck
$TimeFrame = (Get-Date)-$TimeSpan
$TimeText = "Days"

# END REGION RAID Error Event

# --------END OF PARAMETERS and VARIABLES SECTION -----------

#-----FUNCTIONS SECTION ------------------

Function Get-HostUptime {
    param ([string]$ComputerName)
    $Uptime = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName
    $LastBootUpTime = $Uptime.ConvertToDateTime($Uptime.LastBootUpTime)
    $Time = (Get-Date) - $LastBootUpTime
    Return '{0:00} Days, {1:00} Hours, {2:00} Minutes, {3:00} Seconds' -f $Time.Days, $Time.Hours, $Time.Minutes, $Time.Seconds
}

Function Check-RAID{
    # No Event Log Source
    Param ([int]$EventID, [string]$EventLogName, [DateTime]$TimeFrame, [int]$TimeToCheck, [string]$TimeText)
    # Event Log Source Defined
    #Param ([int]$EventID, [string]$EventLogName,[string]$EventLogSource, [DateTime]$TimeFrame, [int]$TimeToCheck, [string]$TimeText)
        
      Write-Output "----------------------------------------------------------------------------------- "
      Write-Output "----------------------------------------------------------------------------------- "
      Write-Output "-EventID $EventID -EventLogName $EventLogName -TimeFrame Last $TimeToCheck $TimeText"
      #Write-Output "-EventID $EventID -EventLogName $EventLogName -EventLogSource $EventLogSource -TimeFrame Last $TimeToCheck $TimeText"
      Write-Output "----------------------------------------------------------------------------------- "
      Write-Output "----------------------------------------------------------------------------------- "
     
      try
      {
        if ((Get-EventLog -ComputerName $ComputerName -LogName $EventLogName -InstanceID $EventID -After $TimeFrame -Newest 1 -ErrorAction Stop) -ne $null)
        #if ((Get-EventLog -ComputerName $ComputerName -LogName $EventLogName -Source $EventLogSource -InstanceID $EventID -After $TimeFrame -Newest 1 -ErrorAction Stop) -ne $null)
        {
           # Print out the First Event detail - that triggered
           Get-EventLog -ComputerName $ComputerName -LogName $EventLogName -InstanceID $EventID -After $TimeFrame -Newest 1
           #Get-EventLog -ComputerName $ComputerName -LogName $EventLogName -Source $EventLogSource -InstanceID $EventID -After $TimeFrame -Newest 1
 
        # Trigger Audio
        Write-Output "----------------------------------------------------------------------------------- "
        Write-Output "----------------------------------------------------------------------------------- "
        Write-Output "---                 RAID event triggered $EventID                               --- "
        Write-Output "---                                                                             ---"
        Write-Output "---                                                                             --- "
        Write-Output "----------------------------------------------------------------------------------- "
           
        # Write to Report
        Write-Output $EventID
        Write-Output "EventID of Interest has been Found"
         }

        else{

            Write-Output "No EventID of Interest has been Found"
        }
       }
    catch 
       {
        Write-Output "----------------------------------------------------------------------------------- "
          Write-Output "---                        Event $EventID does not exist                      --- "
        Write-Output "----------------------------------------------------------------------------------- "
        }
    }

#-----END OF FUNCTIONS SECTION ------------------

$Report = @()
$ReportBody = @()
$Disks = @()
$SystemErrors = @()
$AppErrors = @()

Write-Host $ReportName
Write-Host $Logo1

$Report += Get-HtmlOpenPage  -TitleText ($ReportName) -LeftLogoString $Logo1 #-RightLogoString $Logo1

$ReportBody += Get-HtmlContentOpen -HeaderText "System Report For - $ComputerName"	 -BackgroundShade 2

	#Region System & Disk 
    $CpuData = get-wmiobject win32_processor -computername $ComputerName | measure-object -property LoadPercentage -average | select Average
    $DiskInfo= Get-WMIObject -ComputerName $ComputerName Win32_LogicalDisk | Where-Object{$_.DriveType -eq 3} | Select-Object SystemName, VolumeName, Name, @{n='Size (GB)';e={[math]::Round($($_.size) / 1073741824,2)}}, @{n='FreeSpace (GB)';e={[math]::Round($($_.freespace) / 1073741824,2)}}, @{n="Used (%)";e={[math]::Round($($_.size - $_.freespace) / $_.size * 100,1)}}
	$Disks += $DiskInfo
	$SystemInfo = (Get-WmiObject -Class Win32_OperatingSystem -computername $ComputerName | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory)
	$TotalRAM = ($SystemInfo.TotalVisibleMemorySize/1MB)
	$FreeRAM =($SystemInfo.FreePhysicalMemory/1MB)
	$UsedRAM =($TotalRAM - $FreeRAM)
	$RAMPercentFree = ($FreeRAM / $TotalRAM) * 100
	
	$ReportBody += Get-HtmlContentOpen -HeaderText "System Information" -BackgroundShade 1
		$ReportBody += Get-HTMLColumn1of2
			$ReportBody += Get-HtmlContentOpen -HeaderText "OS Information"
				$ReportBody += Get-HtmlContentText -Heading "OS" -Detail (Get-WmiObject Win32_OperatingSystem -computername $ComputerName).caption
				$ReportBody += Get-HtmlContentText -Heading "Uptime" -Detail (Get-HostUptime -ComputerName $ComputerName)
			    $ReportBody += Get-HtmlContentText -Heading "Total RAM" -detail ([Math]::Round($TotalRAM, 2))
			    $ReportBody += Get-HtmlContentText -Heading "Free RAM" -detail ([Math]::Round($FreeRAM, 2))
			    $ReportBody += Get-HtmlContentText -Heading "Used RAM" -Detail ( [Math]::Round($UsedRAM, 2))
			    $ReportBody += Get-HtmlContentText -Heading "RAM Free %" -Detail ( [Math]::Round($RAMPercentFree, 2))
			$ReportBody += Get-HtmlContentClose
			
			$ReportBody += Get-HtmlContentOpen -HeaderText "Disk Information"
				$ReportBody += Get-HtmlContentTable $DiskInfo
		    $ReportBody += Get-HTMLColumnClose
		$ReportBody += Get-HtmlContentClose
		
        # First disk space Drive Pie Chart Only 
		$ReportBody += Get-HTMLColumn2of2
			$PieChartObject = Get-HTMLPieChartObject      
			$PieChartObject.Title = "Disk Space"
			$PieChartObject.Size.Width = 300
			$PieChartObject.Size.Height = 300
			$DiskSpace = @();$DiskSpaceRecord = '' | select Name, Count
			$DiskSpaceRecord.Count = $DiskInfo.'FreeSpace (GB)'[0];$DiskSpaceRecord.Name = "Free (GB)"
			$DiskSpace += $DiskSpaceRecord;$DiskSpaceRecord = '' | select Name, Count
            $DiskSpaceRecord.Count = $DiskInfo.'Size (GB)'[0] - $DiskInfo.'FreeSpace (GB)'[0] ;$DiskSpaceRecord.Name = "Used (GB)"
			$DiskSpace += $DiskSpaceRecord
			$ReportBody += Get-HTMLPieChart -ChartObject $PieChartObject -DataSet ($DiskSpace)
		$ReportBody += Get-HTMLColumnClose
	$ReportBody += Get-HtmlContentClose
    #endregion
    
	#Region Services & Processes
	$ReportBody += Get-HtmlContentOpen -HeaderText "Processes & Services" #-IsHidden
		$ReportBody += Get-HTMLColumn1of2
			$TopProcesses = Get-Process -ComputerName $ComputerName | Sort WS -Descending | Select ProcessName, Id, WS -First $ProccessNumToFetch #| ConvertTo-Html -Fragment
	    	$ReportBody +=  Get-HtmlContentTable $TopProcesses
		$ReportBody += Get-HtmlColumnClose
		
		$ServicesReport = @()
	    $Services = Get-WmiObject -Class Win32_Service -ComputerName $ComputerName | Where {($_.StartMode -eq "Auto") -and ($_.State -eq "Stopped")}
	    foreach ($Service in $Services) {
	        $row = New-Object -Type PSObject -Property @{
	               Name = $Service.Name
	            Status = $Service.State
	            StartMode = $Service.StartMode
	        }
	    $ServicesReport += $row
	    }
		$ReportBody += Get-HTMLColumn2of2
			$ReportBody += Get-HtmlContentTable $ServicesReport
		$ReportBody += Get-HtmlColumnClose
   	$ReportBody += Get-HtmlContentclose
    #endregion

    #Region Gallagher Backup and Archives report

        # Log of the last 7 days of files
        $targetdate =  (get-date).AddDays(-7)
        #Set Location where Backup files are held
        set-location $GallagherBackup

        $GallagherBackupsReport = @()
		$GallagherBackups = get-childitem $GallagherBackup -Recurse | Select CreationTime, FullName 
        if ($GallagherBackups){
		    foreach ($eventBk in $GallagherBackups) {

                		$rowBk = New-Object -Type PSObject -Property @{
		                CreationTime = $eventBk.CreationTime
		                FullName = $eventBk.FullName
                    }

		        $GallagherBackupsReport += $rowBk
            }#end of foreach   
    
        }
        else{ 	
            $rowBk = New-Object -Type PSObject -Property @{
		        ALERT = "Please Review the Server BACKUPS folder"
		        Files = "No Gallagher Backups Files Found"
            }

		        $GallagherBackupsReport += $rowBk
            }
		$ReportBody += Get-HtmlContentOpen -HeaderText "Gallagher Backup Files List - 7 Days" #-IsHidden
		$ReportBody += Get-HtmlContentTable $GallagherBackupsReport 
		$ReportBody += Get-HtmlContentClose

     # Gallagher Archives
        set-location $GallagherArchives

        $GallagherArchivesReport = @()
		$GallagherArchives = get-childitem $GallagherArchives -Recurse | Select CreationTime, FullName 
        if ($GallagherArchives){
		    foreach ($eventAr in $GallagherArchives) {

                		$rowAr = New-Object -Type PSObject -Property @{
		                CreationTime = $eventAr.CreationTime
		                FullName = $eventAr.FullName
                    }

		        $GallagherArchivesReport += $rowAr
            }#end of foreach   
    
        }
        else{ 	
            $rowAr = New-Object -Type PSObject -Property @{
		        ALERT = "Please Review the Server ARCHIVES folder"
		        Files = "No Gallagher Archive Files Found"
            }

		        $GallagherArchivesReport += $rowAr
        }

        $ReportBody += Get-HtmlContentOpen -HeaderText "Gallagher Archives Files List - 7 Days" #-IsHidden
        $ReportBody += Get-HtmlContentTable $GallagherArchivesReport 
		$ReportBody += Get-HtmlContentClose
  
       #EndRegion Gallagher Backups and Archives

       <# Disable Updates checking for Win Server 2012 and 2016 
       #start Region Windows Updates - Hotfix
    
        $Session = New-Object -ComObject Microsoft.Update.Session            
        $Searcher = $Session.CreateUpdateSearcher()         
        $HistoryCount = $Searcher.GetTotalHistoryCount()                       
        $Searcher.QueryHistory(0,$HistoryCount) | ForEach-Object -Process {            
 
          $Title = $null            
        if($_.Title -match "\(KB\d{6,7}\)"){            
            # Split returns an array of strings            
            $Title = ($_.Title -split '.*\((KB\d{6,7})\)')[1]            
        }else{            
            $Title = $_.Title            
        }  
                       
        $Result = $null            
        Switch ($_.ResultCode)            
        {            
            0 { $Result = 'NotStarted'}            
            1 { $Result = 'InProgress' }            
            2 { $Result = 'Succeeded' }            
            3 { $Result = 'SucceededWithErrors' }            
            4 { $Result = 'Failed' }            
            5 { $Result = 'Aborted' }            
            default { $Result = $_ }            
        }            
            New-Object -TypeName PSObject -Property @{            
            ComputerName = $ENV:Computername;
            InstalledOn = Get-Date -Date $_.Date;            
            KBArticle = $Title;            
            Name = $_.Title;            
            Status = $Result            
        }            
          
        } | Sort-Object -Descending:$true -Property InstalledOn |             
            Select-Object -Property * -outvariable variableHotfix

        $ReportBody += Get-HtmlContentOpen -HeaderText "Installed Windows Updates" #-IsHidden
	    $ReportBody += Get-HtmlContentTable $variableHotfix 
	    $ReportBody += Get-HtmlContentClose

        #end Region Windows updates
        #>

        # Start Region RAID Error Event checking
        Try
        {

                Write-Output "----------------------------------------------------------------------------------- "
                Write-Output "----------------------------------------------------------------------------------- "
                Write-Output "                       Process RAID events                         "
                Write-Output "----------------------------------------------------------------------------------- "
                Write-Output "----------------------------------------------------------------------------------- "
               
                $ReportBody += Get-HtmlContentOpen -HeaderText "RAID Error Events Log - PLEASE INVESTIGATE any RAID ERRORS Listed Below" #-IsHidden

                    foreach ($EventID in $EventIDs)
                    {
                       #Check-RAID -EventID $EventID -EventLogName $EventLogName -TimeFrame $TimeFrame -TimeToCheck $TimeToCheck -TimeText $TimeText
                       Check-RAID -EventID $EventID -EventLogName $EventLogName -EventLogSource $EventLogSource -TimeFrame $TimeFrame -TimeToCheck $TimeToCheck -TimeText $TimeText
                      
                      # Make SURE You have taken this script OFF TEST (Test EventIDs.txt file not referenced) !!!
                      $RAIDEvent = Get-EventLog -ComputerName $ComputerName -LogName $EventLogName | Where-Object {$_.EventID -eq $EventID} | Select-Object -Property EventID,EventType,Message -ErrorAction Silent
                      #$RAIDEvent = Get-EventLog -ComputerName $ComputerName -LogName $EventLogName -Source $EventLogSource | Where-Object {$_.EventID -eq $EventID} | Select-Object -Property EventID,EventType,Message -ErrorAction Silent
                       
                       # If RAID event of note found
                       if ($RAIDevent){
			            
				        $ReportBody += Get-HtmlContentTable $RAIDEvent 
			            
                        }
                        else {
                                  Write-Output "No RAID events found for $EventID ."
                         }
                  
                  } 
                 $ReportBody += Get-HtmlContentClose 
           }
        Catch
           {
                Write-Output "----------------------------------------------------------------------------------- "
            Write-Output "---                   Error Occurred with Script                 --- "
                Write-Output "----------------------------------------------------------------------------------- "
        }
        Finally
        {
            $Time=Get-Date
                Write-Output "----------------------------------------------------------------------------------- "
            Write-Output "---                   Script stopped at $Time            --- " 
                Write-Output "----------------------------------------------------------------------------------- "
        }
    # End Region RAID Error Event checking
        
    #region Event Logs Report
		
	$Appevents = Get-EventLog -ComputerName $ComputerName -LogName Application -EntryType Error   | group  Source | sort count -Descending | select -First 5
	$AppErrors += $Appevents
	$Sysevents = Get-EventLog -ComputerName $ComputerName -LogName System -EntryType Error   | group  Source | sort count -Descending | select -First 5
	$SystemErrors += $Sysevents

	$ReportBody += Get-HtmlContentOpen -HeaderText "Event Logs" 
		$ReportBody += Get-HtmlContentOpen -HeaderText "Top 5 Sources of Errors" 
		$ReportBody +=  Get-HTMLColumn1of2
			$PieChartObject = Get-HTMLPieChartObject      
			$PieChartObject.Title = "System Log Top 5 Errors"
			$PieChartObject.Size.Width = 400
			$PieChartObject.Size.Height = 400
			$ReportBody += Get-HTMLPieChart -ChartObject $PieChartObject -DataSet ($Appevents)
			$ReportBody += Get-HtmlContentTable (Set-TableRowColor ( $Appevents | select name, count) -alternating  )
		$ReportBody += Get-HtmlColumnClose
		$ReportBody +=  Get-HTMLColumn1of2
			$PieChartObject = get-HTMLPieChartObject      
			$PieChartObject.Title = "Application Log 5 Errors"
			$PieChartObject.Size.Width = 400
			$PieChartObject.Size.Height = 400
			$ReportBody += Get-HTMLPieChart -ChartObject $PieChartObject -dataset ($Sysevents)
			$ReportBody += Get-HtmlContentTable (Set-TableRowColor ($Sysevents | select name, count) -alternating  )
		$ReportBody += Get-HtmlColumnClose
		$ReportBody += Get-HtmlContentClose
			
		    $SystemEventsReport = @()
		    $SystemEvents = Get-EventLog -ComputerName $ComputerName -LogName System -EntryType Error -Newest $EventNum
		    foreach ($event in $SystemEvents) {
		        $row = New-Object -Type PSObject -Property @{
		            TimeGenerated = $event.TimeGenerated
		            EntryType = $event.EntryType
		            Source = $event.Source
		            Message = $event.Message
		        }
		        $SystemEventsReport += $row
		    }
		    $ReportBody += Get-HtmlContentOpen -HeaderText "System Event Log" #-IsHidden
				$ReportBody += Get-HtmlContentTable $SystemEventsReport 
			$ReportBody += Get-HtmlContentClose
		    
		    $ApplicationEventsReport = @()
		    $ApplicationEvents = Get-EventLog -ComputerName $ComputerName -LogName Application -EntryType Error -Newest $EventNum
		    foreach ($event in $ApplicationEvents) {
		        $row = New-Object -Type PSObject -Property @{
		            TimeGenerated = $event.TimeGenerated
		            EntryType = $event.EntryType
		            Source = $event.Source
		            Message = $event.Message
		        }
		        $ApplicationEventsReport += $row
		    }
			$ReportBody += Get-HtmlContentOpen -HeaderText "Application Event Log" #-IsHidden
				$ReportBody += Get-HtmlContentTable $ApplicationEventsReport 
			$ReportBody += Get-HtmlContentClose

    #endregion Event Logs

	$ReportBody += Get-HtmlContentClose
	$ReportBody += Get-HtmlContentClose

$Report += Get-HtmlContentOpen -HeaderText "Summary Information" 
$Report += Get-HtmlContentText -Heading "Average CPU Load % "-Detail $CpuData.Average
$Report += Get-HtmlContentClose

$Report += Get-HtmlContentOpen -HeaderText "Detailed Computer Reports"  -BackgroundShade 3
$Report += $ReportBody
$Report += Get-HtmlContentClose 
$Report += Get-HtmlClosePage

# Shows report after running it if you uncomment -showreport
Save-HTMLReport -ReportName $ReportName -ReportContent $Report -ReportPath $ReportOutputPath #-showreport