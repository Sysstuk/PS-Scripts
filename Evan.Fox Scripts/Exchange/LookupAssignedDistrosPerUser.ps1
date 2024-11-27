Connect-ExchangeOnline

#distros
$user = (Get-ADUser -Identity "joe.altomonte").name
$user
$distros = Get-Content -Path "C:\Users\evan.fox\Downloads\Groups (3).csv"
$distros
foreach($distro in $distros) {
    $members = (get-distributiongroupmember -identity $distro).displayname
    if ($members -contains $user) {
        $distroName = (get-distributiongroup -identity $distro).displayname
        Write-Host "$user is a part of $distroName"
    }
}

#365 groups
$groups = Get-Content -Path "C:\Users\evan.fox\Downloads\Groups (4).csv"
foreach($group in $groups) {
    $members = (get-unifiedgrouplinks -identity $group -linktype members).displayname
    if ($members -contains $user) {
        $groupName = (get-unifiedgroup -identity $group).displayname
        Write-Host "$user is a part of $groupName"
    }
}
