#specify path of file being read for list of people to add to group
$users = Get-Content -Path ""
#Enter the name of the group to add the users to
$group = "Adobe Users"
#specifies path of log file using input of filename
$fileName  = "$group user addition log.txt"
#export path of log file using $fileName
$logFile = "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\Groups\$fileName"


#Checks each user to make sure that they 1)exist and 2)aren't disabled before adding to the group
#Writes to the log file whether it failed and why, or succeeded
foreach($user in $users) {
    $termEmp = Get-ADUser -Filter 'SAMAccountName -eq $user'
    if ($termEmp -eq $null) {
        Write-Warning "$empName does not exist."
        Add-Content -Path $logFile -Value "$user doesn't exist`n" 
    } elseif ((Get-ADUser $termEmp).Enabled -eq $False) {
        Write-Warning "$user is already disabled"
        Add-Content -Path $logFile -Value "$user is disabled`n" 
    } else {
        Add-AdGroupmember -Identity $group -Members $user
        Add-Content -Path $logFile -Value "$user added to $group`n"
    }
}