# Check-NetworkTraffic.ps1

# Get Network Traffic Log - for Stats analysis
# Set script to run as a scheduled task Monday- Friday 6 am to 7 pm (peak times)
# Export data to a daily csv file

# List what Network items you can query
(get-counter -list "Network Interface").paths

# Put Date onto Network Traffic Stats Log report
$Now = Get-Date
$ComputerName=$env:COMPUTERNAME
$Report = " `n----------------------------------------------  `n"
$Report += "Network Traffic Stats Report for $ComputerName at [$Now] `n"
$Report += "---------------------------------------------`n`n"
Write-Output $Report

$fileOut = "C:\HealthCheck\"+$ComputerName+"_Network_Traffic_Stats_Report_Date_"+$now.Day+"_"+$now.Month+"_"+$now.Year+"_Time_"+$now.Hour+"_"+$now.Minute+".csv"

# scan for network usage
$all = "\Network Interface(*)\Bytes Received/sec",

"\Network Interface(*)\Bytes Sent/sec",

"\Network Interface(*)\Bytes Total/sec"
        
# Sample every 10 seconds for 13 hours - use in a scheduled task script, starting at 6 am weekedays
Get-Counter -Counter $all -SampleInterval 10 -MaxSamples (6*60*13) | Export-Counter -Path $fileOut -FileFormat CSV -Force
