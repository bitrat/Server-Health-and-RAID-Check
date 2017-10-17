# Server-Health-and-RAID-Check - Powershell scripts

## Installation
* Download/Clone and unzip files into C:\HealthCheck directory on server or a workstation
* If files are unzipped on a workstation, run **Copy-FilesToServer.ps1** to:
    * copy C:\HealthCheck folder onto server
    * copy ReportHTML and ImportExcel Modules into C:\Program Files\WindowsPowerShell\Modules folder on server
 
  Both of the above steps can be done manually.

## Prerequisites
* Powershell v4 (On windows 7 PC's that means installing WMF 5.1, for example)
* For the **Run-SystemReport** script - Create the following folders for the Application daily backups and archives :
    * backups go to C:\Backup
    * archives go to C:\Archives

## System Report - Server Monitoring scripts
These Powershell Scripts do the following (a Windows domain environment is assumed):
* generate a System report with server health stats using the ReportHTML powershell module
* with eventlog analysis - for LSI and P440ar RAID controller Error detection

HTML Report generated - with Stats and RAID Errors:
* **Run-SystemReport_with_RAID_Events_LSI.ps1** - LSI RAID controller
* **Run-SystemReport_with_RAID_Events_P440ar.ps1** - HPE Smart Array 440ar RAID controller

## Audio alerting on RAID Error events script
Audio and Message box alerting on RAID ERRORS - LSI RAID controller MegaRAID java program eventlog analysis:
* **RaidAlert_On_Events.ps1**
* **Beep.ps1**

The audio alerting is for environments where no-one will do a visual check of RAID state.

## Server Performance data gathering scripts
* do network traffic logging - **Check-NetworkTraffic.ps1** 
* performance stats logging - **Check-PerformanceCounters.ps1**

These scripts can be run (on a daily/weekly etc basis) via scheduled tasks.

## Processing Data log scripts
* cleanup csv data log files, convert to xlxs, and line graph - **Process-Server-NetworkAndPerformance-xlxs-Files.ps1**

Note: The processing script relies on the HealthCheck folder structure for processing and filing raw Data after processing.

## Supporting scripts
* **Move-Files.ps1** - HTML Reports and csv files can be moved off the server onto a workstation.
* **Copy-FilesToServer.ps1** - Copy files from a domain workstation to the domain server
* **Remove-Directory.ps1** - Remove HealthCheck folder from remote server

## TO DO :
* Addition to Processing script - generate max, min, average, peak of Network and Server Performance data 
* deal with scheduled task password changes (enforced by domain policy) more elegantly (if possible)




