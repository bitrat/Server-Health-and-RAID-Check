# ARCHIVER RAID ALERTING - RaidAlert_On_Events_LSI.ps1

# MessageBox & Audio Alerts on Client PC
# Scheduled Task - Runs this script once every day - 7:30 am to 5 pm Mon- Fri
# Script scrapes the Archiver MR_MONITOR EventLog for Errors

# Check remote computer (Archiver) is accessible 
$server = "ABC TECH Server Name2"
if (Test-Connection -ComputerName $server -Quiet -Count 1)
{
    Write-Output "----------------------------------------------------------------------------------- "
    Write-Output ("                       SERVER - CONNECTION LIVE             ")
    Write-Output "----------------------------------------------------------------------------------- "

# Audio Alert sequence - when RAID Error Found
$BeepSequence = "C:\Powershell\Beep.ps1"

$EventLogName = "Application"
$EventLogSource = "MR_MONITOR"

# RAID Error Event list
$RAID_events_reference = "C:\HealthCheck\RAID\LSI_RAID_EventIDs.txt"

# Stops processing when it finds first alertable LSI RAID Error eventID
$EventIDs = Get-Content $RAID_events_reference

# Define Time to check events 
# Check last 25 hours (Overlap + in case daylight savings time between Client PC and Archiver PC is out)
$TimeToCheck = 25
$TimeSpan = New-Timespan -Hours $TimeToCheck
$TimeFrame = (Get-Date)-$TimeSpan
$TimeText = "Hours"

# TO DO : Check if a MegaRaid Storage Manager program process is running 
# MegaRaid Storage Manager program process runs as non-descript "javaw.exe"
# Check for Application name instead ?
$Prog = "javaw"

Function Check-RAID{

    # First event triggers audio alert - stops processing other events
    # This limits the amount of Message boxes that can come up, to prevent flooding the system
    # Manual intervention to deal with alerts required once audio alerted
    
    Param ([int]$Freq, [int]$Duration, [int]$EventID, [string]$EventLogName, [DateTime]$TimeFrame, [int]$TimeToCheck, [string]$TimeText)
        
      Write-Output "----------------------------------------------------------------------------------- "
      Write-Output "----------------------------------------------------------------------------------- "
      Write-Output "-Freq $Freq -Duration $Duration -EventID $EventID -EventLogName $EventLogName -TimeFrame Last $TimeToCheck $TimeText"
      Write-Output "----------------------------------------------------------------------------------- "
      Write-Output "----------------------------------------------------------------------------------- "
     
      try
      {
        if ((Get-EventLog -ComputerName $server -LogName $EventLogName -Source $EventLogSource -InstanceID $EventID -After $TimeFrame -Newest 1 -ErrorAction Stop) -ne $null)
        
        {
           # Print out the First Event detail - that triggered
           $RAID_error = Get-EventLog -ComputerName $server -LogName $EventLogName -Source $EventLogSource -InstanceID $EventID -After $TimeFrame -Newest 1
           $RAID_error

        # Trigger Audio
        Write-Output "----------------------------------------------------------------------------------- "
        Write-Output "----------------------------------------------------------------------------------- "
        Write-Output "---                 Audio Triggered on RAID event $EventID                      --- "
        Write-Output "---                 Beep freq: '$Freq' and duration: '$Duration'                ---"
        Write-Output "---                                                                             --- "
        Write-Output "----------------------------------------------------------------------------------- "

        #Create an Output file containing the RAID Error and Message
        try {
            $RAID_error | Add-Content 'C:\HealthCheck\RAID\RAID_LSI_Error_Output.txt'
        }
        Catch {
            Write-Output "---  Could not Write the RAID Error to the C:\HealthCheck\RAID\RAID_LSI_Error_Output.txt File   --- "
        }
           
           # Start separate process is started for BEEPS so the Message Box doesn't silence the beeps until ERROR acknowledged
           $beepBox = Start-Process powershell.exe -Argument $BeepSequence -PassThru -WindowStyle Hidden
                  
           # Message Box needs to always stay on Top 
           Add-Type -AssemblyName Microsoft.VisualBasic
           $acknowledgedMsgBox = [Microsoft.VisualBasic.Interaction]::MsgBox('CRITICAL ERROR - Tell SOMEBODY - there is a FAULT with the "RAID on the Archiver"', 'OkOnly,SystemModal,Critical', 'CRITICAL ERROR - RAID on the Archiver')

        # Beep Until Operator acknowledges Alert Message Box
        if ($acknowledgedMsgBox -eq 'Ok'){
            Stop-Process $beepBox.Id
            break
            }
         }
       }
    catch 
       {
        Write-Output "----------------------------------------------------------------------------------- "
          Write-Output "---                        Event $EventID does not exist                      --- "
        Write-Output "----------------------------------------------------------------------------------- "
        }
    }

Try
{

        Write-Output "----------------------------------------------------------------------------------- "
        Write-Output "----------------------------------------------------------------------------------- "
        Write-Output "                       Process RAID events                         "
        Write-Output "----------------------------------------------------------------------------------- "
        Write-Output "----------------------------------------------------------------------------------- "


            foreach ($EventID in $EventIDs)
            {
                Check-RAID -Freq 700 -Duration 500 -EventID $EventID -EventLogName $EventLogName -TimeFrame $TimeFrame -TimeToCheck $TimeToCheck -TimeText $TimeText
            }
        
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

# Archiver is not responding
# TO DO: Alert that Archiver is not able to be reached (hence Event log not able to be processed) ?
}
else{
Write-Output ("`n.....................................................................")
Write-Output (".... The Server could not be reached to complete this request .......")
Write-Output (".....................................................................")
}

# -------------------------------------------------------------------------

# TO DO: Detect specific RAID Event Levels 
# Log always = Level 0, Critical = Level 1, Error = Level 2 
# Warning = Level 3, Informational = Level 4
# Determine what Level Fatal is 
# Only Information, Warning and Error are -EntryTypes for Get-EventLog
# Get-EventLog -Log "Application" -Source "MR_MONITOR" -ComputerName $server -EntryType Error

# -------------------------------------------------------------------------