Connect-ExchangeOnline
$users = get-aduser -filter * -searchbase "OU=Disabled Users,OU=SEQ,DC=springeq,DC=local"
$users = $users.name
$users
$distros = Get-Content -Path "C:\Users\evan.fox\Downloads\Distros.csv"
$distros
foreach ($user in $users) {
    foreach($distro in $distros) {
        $members = get-distributiongroupmember -identity $distro
        $members = $members.name
        $manager = (get-distributiongroup $distro).managedby
        if($manager -eq $user) {
            Write-Host "$user removed as manager of $distro"
            Set-DistributionGroup $distro -bypassSecuritygroupmanagercheck -managedby @{Remove=$user}
        }
        if ($members -contains $user) {
            #remove-distributiongroupmember -identity $distro -member $user
            Write-Host "$user removed from $distro"
        }
        else {
            Write-Host "$user not a part of $distro"
        }
    }
}

