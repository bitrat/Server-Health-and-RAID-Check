# Example of a WORKGROUP Computer which requires different Credentials
# Install the Credential manager Module first $Install-Module CredentialManager
# Store the Creds in Windows Credential Manager
# Then access Creds with the CredentialManager Module, to login to remote computer
$managedCred = Get-StoredCredential -Target "192.168.30.137" 
Get-WinEvent -LogName Application -ComputerName "192.168.30.137" -Credential $managedCred
