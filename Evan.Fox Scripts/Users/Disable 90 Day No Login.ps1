Connect-MgGraph

#update-mguser -userid "ctd@springeq.com" -accountenabled:$false

$oldUser = [System.Collections.ArrayList]@()
$userBlank = [System.Collections.ArrayList]@()

$oldUserAAD = [System.Collections.ArrayList]@()
$oldUserAADBlank = [System.Collections.ArrayList]@()

$users = get-aduser -filter * -properties name, lastlogondate, whencreated, description -SearchBase "OU=Users,OU=SEQ,DC=springeq,DC=local"

$today = Get-Date
$today
$prevDate = $today.AddDays(-90)
$prevDate
foreach ($obj in $users) { 
    if ((($obj).lastlogondate) -le ($prevDate) -and ((($obj).lastlogondate) -ne $null)) {
       $oldUser.add($obj)
    }
    if ((($obj).lastlogondate) -eq $null) {
        $userBlank.add($obj)
    }
}
$olduser
foreach ($user in $oldUser) {
    if ($user.description -notlike "*LOA*") {
        write-host $user.description
    }
}

$olduser
$oldUser | export-csv -path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\userlogins.csv"
$userBlank | export-csv -path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\userloginsblank.csv"

$aadUsers = get-mguser -all
$aadusers
get-azureaduser -objectid evan.fox@springeq.com | select *

if (((get-azureadauditsigninlogs -Filter "UserPrincipalName eq 'evan.fox@springeq.com'" -Top 1).createddatetime) -gt ($prevDate)) {
    Write-host "Bueno"
}


(get-azureadauditsigninlogs -Filter "UserPrincipalName eq 'evan.fox@springeq.com'" -Top 1).createddatetime

$oldUserAAD | export-csv -path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\AADuserlogins.csv"
$oldUserAADBlank | export-csv -path "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\AADuserloginsBlank.csv"



