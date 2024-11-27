$cred = Get-Credential -Message "Enter la credentials"
[System.Collections.ArrayList]$los = @{}

$users = Get-ADUser -Filter 'Title -like "*Loan Officer*"' -SearchBase "OU=Users,OU=SEQ,DC=springeq,DC=local" -Properties name,proxyaddresses
#$users

$los = foreach($item in $users) {
    [pscustomobject]@{
        Name        = $($item.name)
        Proxies     = $($item.proxyaddresses)
    }
}

$los | Export-Csv -Path "C:\Users\evan.fox\OneDrive - Spring EQ\Documents\LO Original Proxies.csv"

foreach($item in $users) {
    $UPN = ($item).UserPrincipalName
    $firstname = ($item).GivenName
    $lastname = ($item).Surname
    $name = "$firstname.$lastname"
    $newProxy = "$name.express@springeq.com"
    Set-ADUser $item -add @{proxyaddresses="SMTP:$UPN"}
}

Get-ADUser -Filter 'Title -like "*Loan Officer*"' -SearchBase "OU=Users,OU=SEQ,DC=springeq,DC=local" -Properties name,proxyaddresses | select name, @{Name=’proxyAddresses’;Expression={$_.proxyAddresses -join ';'}} | Export-Csv -Path "C:\Users\evan.fox\OneDrive - Spring EQ\Documents\LO New Proxies.csv" -NoTypeInformation