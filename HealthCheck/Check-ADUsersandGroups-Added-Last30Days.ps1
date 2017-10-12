$When = ((Get-Date).AddDays(-30)).Date
Get-ADGroup -Filter {whenChanged -ge $When} -Properties whenChanged #| Export-Csv C:\HealthCheck\NewADUsers.csv -noTypeInformation
Get-ADUser -Filter {whenChanged -ge $When} -Properties whenChanged