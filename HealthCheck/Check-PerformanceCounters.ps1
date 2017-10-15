# Check-PerformanceCounters.ps1

# Get Performance Stats Log - for analysis
# Set script to run as a scheduled task Monday- Friday 6 am to 7 pm (peak times)
# Export data to a daily csv file

# Put Date onto Performance Stats Log report
$Now = Get-Date
$ComputerName=$env:COMPUTERNAME
$Report = " `n----------------------------------------------  `n"
$Report += "Performance Stats Report for $ComputerName at [$Now] `n"
$Report += "---------------------------------------------`n`n"
Write-Output $Report

$fileOut = "C:\HealthCheck\"+$ComputerName+"_Performance_Stats_Report_Date_"+$now.Day+"_"+$now.Month+"_"+$now.Year+"_Time_"+$now.Hour+"_"+$now.Minute+".csv"

# scan for network usage
$all = "\Processor(*)\% Processor Time",
"\Processor(*)\% User Time",
"\Processor(*)\% Privileged Time",
"\Processor(*)\Interrupts/sec",
"\Processor(*)\% Interrupt Time",
"\Processor(*)\DPCs Queued/sec",

# Physical Disk
"\PhysicalDisk(*)\Avg. Disk Write Queue Length",
"\PhysicalDisk(*)\Avg. Disk sec/Read",
"\PhysicalDisk(*)\Avg. Disk sec/Write",
"\PhysicalDisk(*)\% Idle Time",

#Logical Disk
"\LogicalDisk(*)\% Free Space",

# Memory
"\Memory\Available Bytes",
"\Memory\Cache Bytes",
"\Memory\% Committed Bytes In Use",

# Network Interface
"\Network Interface(*)\Bytes Received/sec",
"\Network Interface(*)\Bytes Sent/sec",
"\Network Interface(*)\Bytes Total/sec"
        
# Sample every 15 seconds for 13 hours - use in a scheduled task script, starting at 6 am weekedays
Get-Counter -Counter $all -SampleInterval 15 -MaxSamples (4*60*13) | Export-Counter -Path $fileOut -FileFormat CSV -Force
