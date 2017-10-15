# Process Server Network and Performance .csv files (Results) into .xlxs files
# -------------------------------------------------------------------------------------- #
# Use the Import-Excel PowerShell module
# Does not require Excel to be installed

# Powershell v3 compatible (v5 preferred)

# - With an Internet connection, from an Elevated powershell prompt, type:
#    Install-Module Import-Excel
# - Without Internet - Copy the contents of Import-Excel\Version\*.* 
#    into C:Program Files\WindowsPowerShell\Modules\ImportExcel\ 

# Excel sheet must be closed when you run the script
# -------------------------------------------------------------------------------------- #

# START of processing multiple .csv files
# Define file-locations and delimiter
# TO DO - fix - If converted files already exists - need to acknowledge popup to overwrite
Write-Output "`n------------- CSV FILES ---------------"
if (Get-ChildItem "C:\HealthCheck\" -Filter *.csv) {
 Get-ChildItem "C:\HealthCheck\" -Filter *.csv | %{
    $Path = $_.DirectoryName
    $filename = $_.BaseName

    #Define locations and delimiter
    $csv = $_.FullName #Location of the source file
    #$xlsx = "$Path/$filename.xlsx" # Names & saves Excel file same name/location as CSV
    $xlsx = "C:\HealthCheck\$filename.xlsx" # Names Excel file same name as CSV

    $delimiter = "," #Specify the delimiter used in the file

    # Create a new Excel workbook with one empty sheet
    $excel = New-Object -ComObject excel.application 
    $workbook = $excel.Workbooks.Add(1)
    $worksheet = $workbook.worksheets.Item(1)

    # Build the QueryTables.Add command and reformat the data
    $TxtConnector = ("TEXT;" + $csv)
    $Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
    $query = $worksheet.QueryTables.item($Connector.name)
    $query.TextFileOtherDelimiter = $delimiter
    $query.TextFileParseType  = 1
    $query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
    $query.AdjustColumnWidth = 1

    # Execute & delete the import query
    $query.Refresh()
    $query.Delete()

    # Save & close the Workbook as XLSX.
    $Workbook.SaveAs($xlsx,51)
    $excel.Quit()
 }
}else {
    Write-Output "  No .csv files found in the Directory  "

 }
Write-Output "------------- CSV FILES END -----------"
#END of processing multiple .csv files

# START of NETWORK TRAFFIC Results Processing
Write-Output "`n------------- NETWORK TRAFFIC ---------"

# CHANGE
# Create the folder C:\HealthCheck\NetworkTrafficResults to Output cleaned up Results
if ((Get-ChildItem "C:\HealthCheck\" -Filter *Network_Traffic*.xlsx) -And (Get-ChildItem "C:\HealthCheck\" -Filter *Network_Traffic*.csv)) {
 Get-ChildItem "C:\HealthCheck\" -Filter *Network_Traffic*.xlsx | 
    Foreach-Object { 
        $content = Get-Content $_.FullName 
        $content
        #filter and save content to the original file 
        #$content | Where-Object {$_ -match 'step[49]'} | Set-Content $_.FullName 

        #filter and save content to a new file 
        #$content | Where-Object {$_ -match 'step[49]'} | Set-Content ($_.BaseName + '_out.log') 
    
        $filename = $_.BaseName
        $new_filename = $filename+'_CLEANED'

        # Import and Rename Headers in the Network Excel sheet
        $Imported = Import-Excel -Path "C:\HealthCheck\$filename.xlsx" -HeaderName 'DateTime','BytesReceived0','BytesReceived','BytesReceived1','BytesSent0','BytesSent','BytesSent1','BytesTotal0','BytesTotal','BytesTotal1' -StartRow 3
        # Select just the Columns with the actual values
        # Export xlsx file to another directory, otherwise it becomes part of an infinite processing loop
        $NetworkData = $Imported | Select-Object 'DateTime','BytesReceived','BytesSent','BytesTotal'
        #$NetworkData | Export-Excel -Path "C:\HealthCheck\Results\NetworkTrafficResults\$new_filename.xlsx" 
        $NetworkData

        $c = New-ExcelChart -Title 'Network Traffic' `
            -ChartType Line  `
            -XRange "Network[DateTime]" `
            -YRange @("Network[BytesReceived]","Network[BytesSent]","Network[BytesTotal]") `
            -NoLegend
            #-SeriesHeader 'BytesReceived','BytesSent','BytesTotal'

    # TO DO - fix - Series Legend in Excel sheet shows up wrong
        $NetworkData | 
            #Export-Excel -Path "C:\HealthCheck\Results\NetworkTrafficResults\$new_filename.xlsx" -Numberformat '0.00' -AutoSize -TableName Network -Show -ExcelChartDefinition $c
            Export-Excel -Path "C:\HealthCheck\Results\NetworkTrafficResults\$new_filename.xlsx" -Numberformat '0.00' -AutoSize -TableName Network -ExcelChartDefinition $c

        # Move the Raw Data .xlxs and .csv files
        $origRawDataFolder = "C:\HealthCheck\" ## enter current source folder
        $destRawDataFolder = "C:\HealthCheck\RawData\" ## enter your destination folder 

        Get-ChildItem -Path "C:\HealthCheck\$filename.xlsx" | Move-Item -Destination $destRawDataFolder -Force
        Get-ChildItem -Path "C:\HealthCheck\$filename.csv" | Move-Item -Destination $destRawDataFolder -Force
 }
} else {
    Write-Output "  No Excel files found in the Directory  "
}
Write-Output "------------- NETWORK TRAFFIC END -----"
# END of NETWORK TRAFFIC Results Processing

# START of PERFORMANCE Results Processing

Write-Output "`n------------- PERFORMANCE DATA ---------"

# CHANGE
# Create the folder C:\HealthCheck\PerformanceResults to Output cleaned up Results
if ((Get-ChildItem "C:\HealthCheck\" -Filter *Performance_Stats*.xlsx)-And (Get-ChildItem "C:\HealthCheck\" -Filter *Performance_Stats*.csv)) {
 Get-ChildItem "C:\HealthCheck\" -Filter *Performance_Stats*.xlsx | 
    Foreach-Object { 
        $contentPerf = Get-Content $_.FullName 
        $contentPerf
    
        $filenamePerf = $_.BaseName
        $new_filenamePerf = $filenamePerf+'_CLEANED'

        # Import and Rename Headers in the Performance Excel sheet
        $ImportedPerf = Import-Excel -Path "C:\HealthCheck\$filenamePerf.xlsx" -HeaderName 'DateTime',`
        'PercentProcessorTime0','PercentProcessorTime 1','PercentProcessorTime2','PercentProcessorTime3','PercentProcessorTime4','PercentProcessorTime5','PercentProcessorTime6','PercentProcessorTime7','PercentProcessorTimeTotal',`
        'PercentProcessUserTime0','PercentProcessUserTime1','PercentProcessUserTime2','PercentProcessUserTime3','PercentProcessUserTime4','PercentProcessUserTime5','PercentProcessUserTime6','PercentProcessUserTime7','PercentProcessUserTimeTotal',`
        'PercentProcessPrivTime0','PercentProcessPrivTime1','PercentProcessPrivTime2','PercentProcessPrivTime3','PercentProcessPrivTime4','PercentProcessPrivTime5','PercentProcessPrivTime6','PercentProcessPrivTime7','PercentProcessPrivTimeTotal',`
        'ProcessorInterruptPerSec0','ProcessorInterruptPerSec1','ProcessorInterruptPerSec2','ProcessorInterruptPerSec3','ProcessorInterruptPerSec4','ProcessorInterruptPerSec5','ProcessorInterruptPerSec6','ProcessorInterruptPerSec7','ProcessorInterruptPerSecTotal',`
        'PercentProcessorInterruptTime0','PercentProcessorInterruptTime1','PercentProcessorInterruptTime2','PercentProcessorInterruptTime3','PercentProcessorInterruptTime4','PercentProcessorInterruptTime5','PercentProcessorInterruptTime6','PercentProcessorInterruptTime7','PercentProcessorInterruptTimeTotal',`
        'ProcessorDPCSQueuePerSec0','ProcessorDPCSQueuePerSec1','ProcessorDPCSQueuePerSec2','ProcessorDPCSQueuePerSec3','ProcessorDPCSQueuePerSec4','ProcessorDPCSQueuePerSec5','ProcessorDPCSQueuePerSec6','ProcessorDPCSQueuePerSec7','ProcessorDPCSQueuePerSecTotal',`
        'AvgDiskWriteQueueLength0d','AvgDiskWriteQueueLength1c','AvgDiskWriteQueueLengthTotal',`   
        'AvgDiskSecPerRead0d','AvgDiskSecPerRead1c','AvgDiskSecPerReadTotal',`   
        'AvgDiskSecPerWrite0d','AvgDiskSecPerWrite1c','AvgDiskSecPerWriteTotal',`  
        'DiskPercentIdleTime0d','DiskPercentIdleTime1c','DiskPercentIdleTimeTotal',`  
        'LogicalDiskFreePercentFree_d','LogicalDiskFreePercentFree_c','LogicalDiskFreePercentFree_hd5','LogicalDiskFreePercentFree_Total',` 
        'Memory_AvailBytes','Memory_CacheBytes','Memory_PercentCommittedBytesInUse',`  
        'BytesReceived0','BytesReceived','BytesReceived1','BytesSent0','BytesSent','BytesSent1','BytesTotal0','BytesTotal','BytesTotal1' `
        -StartRow 3

        # Select just the Columns with the actual values - i.e. Totals/Averages
        # Export xlsx file to another directory, otherwise it becomes part of an infinite processing loop
        $NetworkDataPerf = $ImportedPerf | Select-Object 'DateTime','PercentProcessorTimeTotal','PercentProcessUserTimeTotal','PercentProcessPrivTimeTotal','ProcessorInterruptPerSecTotal','PercentProcessorInterruptTimeTotal','ProcessorDPCSQueuePerSecTotal','AvgDiskWriteQueueLengthTotal','AvgDiskSecPerReadTotal','AvgDiskSecPerWriteTotal','DiskPercentIdleTimeTotal','LogicalDiskFreePercentFree_d','LogicalDiskFreePercentFree_c','LogicalDiskFreePercentFree_hd5','Memory_AvailBytes','Memory_CacheBytes','Memory_PercentCommittedBytesInUse','BytesReceived','BytesSent','BytesTotal'
        $NetworkDataPerf | Export-Excel -Path "C:\HealthCheck\Results\PerformanceResults\$new_filenamePerf.xlsx" 

        # Move the Raw Data .xlxs and .csv files
        $origRawDataFolder = "C:\HealthCheck\" ## enter current source folder
        $destRawDataFolder = "C:\HealthCheck\RawData\" ## enter your destination folder 

        Get-ChildItem -Path "C:\HealthCheck\$filenamePerf.xlsx" | Move-Item -Destination $destRawDataFolder -Force
        Get-ChildItem -Path "C:\HealthCheck\$filenamePerf.csv" | Move-Item -Destination $destRawDataFolder -Force
 }
} else {
    Write-Output "  No Excel files found in the Directory  "
}
Write-Output "------------- PERFORMANCE DATA END -----"

# END of PERFORMANCE Results Processing
