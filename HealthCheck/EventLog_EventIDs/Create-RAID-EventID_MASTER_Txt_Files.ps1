# Create-RAID-EventID_MASTER_Txt_Files.ps1

# Creates a Master event ID list file for the RAID events to check for
# based on the Level of Error Detection you want

Function Select_RAID_EventIds {

param(
    # These are the switches to select the RAID controller in use
    [switch] $LSI,
    [switch] $P440ar,
    # This switch gets rid of Warning EventIds and only alerts on higher level Errors
    [switch] $HIGH

)
 
if($LSI){ 

    # Create a New combined event ID file for the LSI events to check for
    # Overwrite any already existing LSI_EventIDs.txt 
    New-Item -ItemType file "C:\HealthCheck\RAID\LSI_RAID_EventIDs.txt" –force
	
    if($HIGH){
    # -HIGH switch used = Fatal, Error, Critical
    # Appends by default
    Get-Content C:\HealthCheck\CCTV\LSI_MR_Monitor_RAID_Events_FATAL.txt | Add-Content C:\HealthCheck\RAID\LSI_RAID_EventIDs.txt
    Get-Content C:\HealthCheck\CCTV\LSI_MR_Monitor_RAID_Events_CRITICAL.txt | Add-Content C:\HealthCheck\RAID\LSI_RAID_EventIDs.txt
    Get-Content C:\HealthCheck\CCTV\LSI_MR_Monitor_RAID_Events_ERROR.txt | Add-Content C:\HealthCheck\RAID\LSI_RAID_EventIDs.txt

    }
    else {
        # ALL Errors checked = Fatal, Error, Critical, Warning
        Get-Content C:\HealthCheck\CCTV\LSI*.txt | Add-Content C:\HealthCheck\RAID\LSI_RAID_EventIDs.txt
    }
 }

elseif($P440ar){

    # Create a combined event ID file for the P440ar Smart array events to check for
    # Overwrite any already existing P440ar_RAID_EventIDs.txt 
    # -ALL switch used = Error, Warning
    New-Item -ItemType file "C:\HealthCheck\RAID\P440ar_RAID_EventIDs.txt" –force
	
    if($HIGH){

        # -HIGH switch used = Error Only
        # Appends by default
        Get-Content C:\HealthCheck\CCTV\HPE_SmartArray_P440ar_ERROR.txt | Add-Content C:\HealthCheck\RAID\P440ar_RAID_EventIDs.txt
    }
    else {

        # ALL Errors checked = Fatal, Error, Critical, Warning
        Get-Content C:\HealthCheck\CCTV\HPE*.txt | Add-Content C:\HealthCheck\RAID\P440ar_RAID_EventIDs.txt
       }
 }
else {

    Write-Output "Choose the RAID type using either Switch -LSI or -P440ar"

    }
}

#Select_RAID_EventIds -LSI -HIGH
#Select_RAID_EventIds -P440ar -HIGH

# All RAID events - Level Warning upwards
Select_RAID_EventIds -LSI 
Select_RAID_EventIds -P440ar 