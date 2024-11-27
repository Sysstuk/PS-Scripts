Connect-ExchangeOnline

New-DynamicDistributionGroup -Name "DL - Team Connelly" -DisplayName "Team Connelly"  -RecipientFilter "((Manager -eq 'CN=Bridget Connelly,OU=Users,OU=SEQ,DC=springeq,DC=local') -or (DistinguishedName -eq 'CN=Bridget Connelly,OU=springeq365.onmicrosoft.com,OU=Microsoft Exchange Hosted Organizations,DC=NAMPR10A010,DC=PROD,DC=OUTLOOK,DC=COM')) -and (RecipientTypeDetails -eq '1')" -PrimarySmtpAddress "ddl-teamconnelly@springeq.com"

Set-DynamicDistributionGroup -identity "DL - Team Connelly" -RecipientFilter "((Manager -eq 'CN=Bridget Connelly,OU=springeq365.onmicrosoft.com,OU=Microsoft Exchange Hosted Organizations,DC=NAMPR10A010,DC=PROD,DC=OUTLOOK,DC=COM') -or (DistinguishedName -eq 'CN=Bridget Connelly,OU=springeq365.onmicrosoft.com,OU=Microsoft Exchange Hosted Organizations,DC=NAMPR10A010,DC=PROD,DC=OUTLOOK,DC=COM') -or (DistinguishedName -eq 'CN=Tom Ricevuto,OU=springeq365.onmicrosoft.com,OU=Microsoft Exchange Hosted Organizations,DC=NAMPR10A010,DC=PROD,DC=OUTLOOK,DC=COM')) -and (RecipientTypeDetails -eq '1')"
Set-DynamicDistributionGroup -identity "DL - Team Henderson (Loan Wolves)" -emailaddresses "SMTP:ddl-teamhenderson@springeq.com","smtp:teamhenderson@springeq.com","smtp:teamhenderson@springeq365.onmicrosoft.com"


(get-dynamicdistributiongroupmember -identity "DL - Ohio Office").displayname | out-file -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\DDL-OH Members.txt"
(get-dynamicdistributiongroupmember -identity "ddl-nj@springeq.com").displayname

get-mailbox "bhenderson@springeq.com" | select-object *
$manager = get-aduser bhenderson
(get-aduser -Filter "Manager -eq '$manager'" -properties *).displayname | out-file -filepath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\bentonusers.txt"

get-dynamicdistributiongroup -identity "ddl-teamkasian@springeq.com" | select-object *
set-dynamicdistributiongroup -identity "ddl-teamhenderson@springeq.com" -DisplayName "Team Henderson (Loan Wolves)"



#check if user is in dynamic distro
if (((get-dynamicdistributiongroupmember -identity "ddl-allstaff@springeq.com").displayname) -contains "Joe Steffa") {
    Write-Host "True"
}
(get-dynamicdistributiongroupmember -identity "ddl-allstaff@springeq.com").displayname


#Look up distros the user is a part of
Connect-ExchangeOnline
$path = "C:\Users\evan.fox\onedrive - spring eq\Desktop\UserDistros.xlsx"
Export-Excel $path -worksheetname "UserDistros"
$ExcelPkg = Open-ExcelPackage -Path $path
$workSheet = $excelpkg.Workbook.Worksheets["UserDistros"]
$workCells = $excelpkg.Workbook.Worksheets["UserDistros"].Cells
$users = get-content -LiteralPath "C:\Users\evan.fox\OneDrive - Spring EQ\Desktop\InputNames.txt"

$userRow = 1
$UserColumn = 1
$DistroRow = 2
foreach ($user in $users) {
    $workCells[$userRow,$userColumn].value = $user
    
    $username = (get-aduser -filter "Name -eq '$user'").userprincipalname
    $DistributionGroups = Get-DistributionGroup | where { (Get-DistributionGroupMember $_.Name | foreach {$_.PrimarySmtpAddress}) -contains "$Username"}
    foreach ($distro in $distributionGroups){
        $workCells[$distroRow,$userColumn].value = $distro
        $DistroRow++
    }
    $distroRow = 2
    $userColumn++
}
Close-ExcelPackage $ExcelPkg



#Remove user from all distros they are assigned to
Connect-ExchangeOnline
$username = "bob.marseilles@springeq.com"
$DistributionGroups= Get-DistributionGroup | where { (Get-DistributionGroupMember $_.Name | foreach {$_.PrimarySmtpAddress}) -contains "$Username"}
$DistributionGroups

foreach ($distro in $distributionGroups) {
    #Write-host $distro.displayname
    Remove-DistributionGroupMember -Identity $distro.displayname -Member "Bob Marseilles"
}


Connect-AzureAD