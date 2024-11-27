Connect-MgGraph

$staleDate = (get-date).adddays(-90)
$newAcctDate = (get-date).adddays(-30)
$today = get-date -format filedate

$staleUsers = [System.Collections.ArrayList]@()
$staleContractors = [System.Collections.ArrayList]@()
$staleAdmins = [System.Collections.ArrayList]@()
$exportList = [System.Collections.ArrayList]@()

#Pulls users who are active, members, and onpremsynced (to differentiate from apps/automation accounts)
#Accounts must be older than 30 days and haven't signed in for 90 days
$staleUsers = get-mguser -filter "accountenabled eq true and usertype eq 'member' and onpremisessyncenabled eq true" -all -select displayname,userprincipalname,signinactivity,createddatetime | where-object {($_.signinactivity.lastsignindatetime -lt $staleDate) -and ($_.createddatetime -lt $newAcctDate)}

#Checks the Security Delegation OU for stale accounts based on the modify property and age of account
$staleAdmins = get-aduser -filter 'Enabled -eq $true' -SearchBase "OU=Security Delegation,OU=SEQ,DC=springeq,DC=local" -properties * | Where-Object {($_.modified -lt $staledate) -and ($_.Created -lt $newAcctDate)}

#disabling report
foreach ($user in $staleUsers){
    $person = get-aduser -Filter "Name -eq '$($user.displayname)'" -properties *
    if ($person.description -notlike "*LOA*") {
        if(((($person.DistinguishedName) -like '*OU=Partners*')) -and ($person.lastlogondate -lt $staledate)){
            $object = [PSCustomObject]@{
                Name = $user.displayname
                Title = $person.description
                Last_Logon = $user.signinactivity.lastsignindatetime
            }
            $exportList.add($object)
            Disable-AdAccount -Identity $person.SAMAccountName
            Move-ADObject -Identity $person -TargetPath "OU=Disabled Partners,OU=Disabled Users,OU=SEQ,DC=springeq,DC=local"
        }
        elseif (((($person.DistinguishedName) -like '*OU=Users*')) -and ($person.lastlogondate -lt $staledate)){
            $object = [PSCustomObject]@{
                Name = $user.displayname
                Title = $person.description
                Last_Logon = $user.signinactivity.lastsignindatetime
            }
            $exportList.add($object)
            Disable-AdAccount -Identity $person.SAMAccountName
            Move-ADObject -Identity $person -TargetPath "OU=Disabled Users,OU=SEQ,DC=springeq,DC=local"
        }
    }
}
foreach ($user in $staleadmins) {
        $object = [PSCustomObject]@{
            Name = $user.displayname
            Title = $user.description
            Last_Logon = $user.signinactivity.lastlogondate
        }
        $exportList.add($object)
        Disable-AdAccount -Identity $person.SAMAccountName
}
$exportList | Export-Excel "\\springeq.local\dfs\office\it\Script Logs\StaleComputers\Users $today.xlsx"

