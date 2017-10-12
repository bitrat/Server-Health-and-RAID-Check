# Check-PerformanceCounters.ps1

# Get Data Points for server performance - 10 second intervals
# Set script to run as a scheduled task Monday- Friday 6 am to 7 pm (peak times)
# Export data to a daily csv file

$Now = Get-Date
$ComputerName=$env:COMPUTERNAME
$fileOut = "C:\HealthCheck\"+$ComputerName+"_Performance_Stats_Report_Date_"+$now.Day+"_"+$now.Month+"_"+$now.Year+"_Time_"+$now.Hour+"_"+$now.Minute+".csv"

$processor = (Get-Counter -listset processor).paths

$physicalDisk = (Get-Counter -listset physicaldisk).paths

$memory = (Get-Counter -listset memory).paths

$network = (Get-Counter -listset 'network interface').paths

$mycounters = $processor + $physicalDisk + $memory + $network

# Sample every 10 seconds for 13 hours - use in a scheduled task script, starting at 6 am weekedays
Get-Counter -Counter $mycounters -SampleInterval 10 -MaxSamples (6*60*13) | Export-Counter -Path $fileOut -FileFormat CSV -Force


