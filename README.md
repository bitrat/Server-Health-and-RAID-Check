# Server-Health-and-RAID-Check - Powershell scripts

## Installation
* Download/Clone and unzip files into C:\HealthCheck directory on server or a workstation
* If files unzipped on a workstation, run **Copy-FilesToServer.ps1** to:
    * copy C:\HealthCheck folder onto server
    * copy ReportHTML Module into C:\Program Files\WindowsPowerSehll\Modules folder on server
 
  Both of the above steps can be done manually.

## Prerequisites
* Powershell v4 (On windows 7 PC's that means installing WMF 5.1, for example)
* For Run-SystemReport script - Assume any Application daily backups and archives you want listed in weekly report :
    * backups go to C:\Backup
    * archives go to C:\Archives

## Main Scripts
These Powershell Scripts do the following (a Windows domain environment is assumed):
* generate a System report with server health stats using the ReportHTML powershell module
* with eventlog analysis - for LSI and P440ar RAID controller Error detection

HTML Report generated - with Stats and RAID Errors:
* **Run-SystemReport_with_RAID_Events_LSI.ps1** - LSI RAID controller
* **Run-SystemReport_with_RAID_Events_P440ar.ps1** - HPE Smart Array 440ar RAID controller

Audio and Message box alerting on RAID ERRORS - LSI RAID controller MegaRAID java program eventlog analysis:
* **RaidAlert_On_Events.ps1**
* **Beep.ps1**

The audio alerting is for environments where no-one will do a visual check of RAID state.

* do network traffic logging - **Check-NetworkTraffic.ps1** 
* performance stats logging - **Check-PerformanceCounters.ps1**
These scripts can be run (on a daily/weekly etc basis) via scheduled tasks.

## Supporting scripts
* **Move-Files.ps1** - HTML Reports and csv files can be moved off the server onto a workstation.
* **Copy-FilesToServer.ps1** - Copy files from a domain workstation to the domain server

## TO DO :
* Process csv files of Network and performance data - generate useful report beyond max, min, average, peak
* deal with scheduled task password changes (enforced by domain policy) more elegantly (if possible)




